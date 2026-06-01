"""render_pdfs.py

Renderiza PDFs a PNG con PyMuPDF a 170-180 DPI (suficiente para Read multimodal).

Uso:
    python render_pdfs.py <pdf_dir> <output_dir> [--dpi 180] [--prefix-map mapping.json]

mapping.json (opcional):
    {"archivo1.pdf": "T1", "archivo2.pdf": "T2"}

Si no se pasa mapping, usa el nombre del PDF como prefijo (sin extensión).

Output: <output_dir>/<prefix>_p<NNN>.png
"""
import fitz, os, sys, json, argparse

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf_dir")
    ap.add_argument("output_dir")
    ap.add_argument("--dpi", type=int, default=180)
    ap.add_argument("--prefix-map", default=None,
                    help="JSON file con mapeo {filename: prefix}")
    args = ap.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)

    mapping = {}
    if args.prefix_map and os.path.exists(args.prefix_map):
        with open(args.prefix_map, encoding="utf-8") as f:
            mapping = json.load(f)

    mat = fitz.Matrix(args.dpi / 72, args.dpi / 72)
    total = 0
    for pdf_name in sorted(os.listdir(args.pdf_dir)):
        if not pdf_name.lower().endswith(".pdf"):
            continue
        src = os.path.join(args.pdf_dir, pdf_name)
        prefix = mapping.get(pdf_name, os.path.splitext(pdf_name)[0])
        # Sanitize prefix
        prefix = "".join(c if c.isalnum() else "_" for c in prefix)[:30]
        doc = fitz.open(src)
        n = len(doc)
        for i, page in enumerate(doc, start=1):
            pix = page.get_pixmap(matrix=mat, alpha=False)
            out = os.path.join(args.output_dir, f"{prefix}_p{i:03d}.png")
            pix.save(out)
            total += 1
        print(f"{prefix}: {n} pages")
        doc.close()
    print(f"TOTAL: {total} pages")

if __name__ == "__main__":
    main()
