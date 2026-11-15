#!/usr/bin/env python3
"""Собирает datasheet_v1_*.docx из Markdown и заполняет СОДЕРЖАНИЕ.

Шаблон md2docx оставляет страницу СОДЕРЖАНИЕ пустой (это не поле Word), поэтому
скрипт сам вставляет строки оглавления и подставляет номера страниц, вычисленные
по отрендеренному PDF. Номера пересчитываются итеративно, пока разметка не
стабилизируется.

    cd conv_accel/docs
    python3 ../scripts/make_datasheet.py datasheet_v1_20261115.md
"""
import os
import re
import shutil
import subprocess
import sys

from docx import Document
from docx.shared import Pt, Cm, Mm
from docx.enum.text import WD_TAB_ALIGNMENT, WD_TAB_LEADER

MD2DOCX = "/home/selbizo-pc/.config/opencode/skills/md2docx/md_to_docx.py"
OUTDIR = "/tmp/conv_accel_doc"
ENTRY_PT = 11.5
ENTRY_LS = 0.9


def run(cmd, **kw):
    return subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL,
                          stderr=subprocess.DEVNULL, **kw)


def docx_to_md(md):
    out = os.path.splitext(md)[0] + ".docx"
    run([sys.executable, MD2DOCX, md, out])
    return out


def set_a4(path):
    d = Document(path)
    for s in d.sections:
        s.page_width, s.page_height = Mm(210), Mm(297)
    d.save(path)


def headings(d):
    out = []
    for p in d.paragraphs:
        st, t = p.style.name, p.text.strip()
        if not t:
            continue
        if st in ("Заголовок", "Заголовок 1"):
            if t in ("РЕФЕРАТ", "СОДЕРЖАНИЕ"):
                continue
            out.append((1, t))
        elif st == "Заголовок 2":
            out.append((2, t))
    return out


EQ_IMAGES = [("img/eq1.png", 9.2), ("img/eq2.png", 4.6)]


def replace_formulas(path):
    """OMML-формулы не отображаются без шрифта Cambria Math, поэтому заменяем
    их на заранее отрендеренные картинки (matplotlib mathtext)."""
    from docx.oxml.ns import qn
    base = os.path.dirname(os.path.abspath(path))
    d = Document(path)
    k = 0
    for p in d.paragraphs:
        if not p._p.findall(".//" + qn("m:oMath")):
            continue
        for child in list(p._p):
            if child.tag != qn("w:pPr"):
                p._p.remove(child)
        if k < len(EQ_IMAGES):
            img, w = EQ_IMAGES[k]
            p.add_run().add_picture(os.path.join(base, img), width=Cm(w))
        k += 1
    d.save(path)
    print(f"формул заменено картинками: {k}")


def insert_placeholders(path):
    d = Document(path)
    ents = headings(d)
    idx = next(i for i, p in enumerate(d.paragraphs) if p.text.strip() == "СОДЕРЖАНИЕ")
    anchor = d.paragraphs[idx + 1]
    sec = d.sections[0]
    text_w = sec.page_width - sec.left_margin - sec.right_margin
    body = d.styles["Обычный"]
    for _ in ents:
        p = anchor.insert_paragraph_before()
        p.style = body
        pf = p.paragraph_format
        pf.first_line_indent = Cm(0)
        pf.left_indent = Cm(0)
        pf.space_before = Pt(0)
        pf.space_after = Pt(0)
        pf.line_spacing = ENTRY_LS
        pf.tab_stops.add_tab_stop(text_w, WD_TAB_ALIGNMENT.RIGHT, WD_TAB_LEADER.DOTS)
    d.save(path)
    return ents


def toc_paragraphs(d, n):
    idx = next(i for i, p in enumerate(d.paragraphs) if p.text.strip() == "СОДЕРЖАНИЕ")
    return d.paragraphs[idx + 1: idx + 1 + n]


_render_seq = [0]


def render_pages(docx):
    # уникальная копия на каждую итерацию: иначе LibreOffice отдаёт
    # закешированный результат для того же пути
    _render_seq[0] += 1
    stem = f"render_{_render_seq[0]}"
    tmp_docx = os.path.join(OUTDIR, stem + ".docx")
    shutil.copyfile(docx, tmp_docx)
    pdf = os.path.join(OUTDIR, stem + ".pdf")
    if os.path.exists(pdf):
        os.remove(pdf)
    run(["libreoffice", "--headless", "--convert-to", "pdf", "--outdir", OUTDIR, tmp_docx])
    txt = subprocess.run(["pdftotext", "-layout", pdf, "-"], check=True,
                         capture_output=True, text=True).stdout
    return [re.sub(r"\s+", " ", s) for s in txt.split("\f")]


def find_page(pages, start, heading):
    key = re.sub(r"\s+", " ", heading).lower()
    for n in range(start, len(pages) + 1):
        if key in pages[n - 1].lower():
            return n
    for n in range(start, len(pages) + 1):
        if key[:18] in pages[n - 1].lower():
            return n
    return None


def main():
    md = sys.argv[1]
    os.makedirs(OUTDIR, exist_ok=True)
    docx = docx_to_md(md)
    set_a4(docx)
    replace_formulas(docx)
    ents = insert_placeholders(docx)

    for it in range(7):
        pages = render_pages(docx)
        # тело начинается там, где стоит первый абзац ВВЕДЕНИЯ: так мы не ловим
        # строки самого оглавления
        body_start = next((n for n, p in enumerate(pages, 1)
                           if n >= 3 and "Настоящий документ описывает" in p), 4)
        d = Document(docx)
        changed = 0
        for p, (lvl, title) in zip(toc_paragraphs(d, len(ents)), ents):
            pg = find_page(pages, body_start, title)
            if pg is None:
                continue
            if lvl == 2:
                p.paragraph_format.left_indent = Cm(1.0)
            num = "" if pg is None else str(pg)
            if not p.runs:
                r1 = p.add_run(title)
                r1.font.size = Pt(ENTRY_PT)
                r2 = p.add_run("\t" + num)
                r2.font.size = Pt(ENTRY_PT)
                changed += 1
            else:
                if p.runs[-1].text.strip() != num:
                    changed += 1
                p.runs[-1].text = "\t" + num
        print(f"итерация {it}: страниц {len(pages)}, правок {changed}")
        if changed == 0:
            break
        d.save(docx)

    print("готово:", docx)


if __name__ == "__main__":
    main()
