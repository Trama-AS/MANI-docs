import os
import sys
import base64
import markdown
import subprocess

current_dir = os.path.dirname(os.path.abspath(__file__))
md_path = os.path.join(current_dir, 'Documento_Herramientas_Politicas_Lineamientos_V2.md')
pdf_path = os.path.join(current_dir, 'Documento_Herramientas_Politicas_Lineamientos_V2.pdf')
html_path = os.path.join(current_dir, 'temp_doc.html')

with open(md_path, 'r', encoding='utf-8') as f:
    md_text = f.read()

# Encode images to base64 so Edge renders them self-contained
img_alto_nivel_path = os.path.join(current_dir, 'img', 'DiagramaTecnologiasAltoNivel.jpg')
img_radar_path = os.path.join(current_dir, 'img', 'TechRadar.png')

with open(img_alto_nivel_path, 'rb') as f:
    b64_alto_nivel = base64.b64encode(f.read()).decode('utf-8')

with open(img_radar_path, 'rb') as f:
    b64_radar = base64.b64encode(f.read()).decode('utf-8')

# Replace markdown image links with base64 data URIs
md_text = md_text.replace('./img/DiagramaTecnologiasAltoNivel.jpg', f'data:image/jpeg;base64,{b64_alto_nivel}')
md_text = md_text.replace('./img/TechRadar.png', f'data:image/png;base64,{b64_radar}')

html_body = markdown.markdown(md_text, extensions=['tables', 'fenced_code', 'toc'])

css_content = """
@page {
    size: A4;
    margin: 18mm 15mm 20mm 15mm;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    color: #1e293b;
    line-height: 1.55;
    font-size: 9.5pt;
    margin: 0;
    padding: 0;
}

header-banner {
    display: block;
    background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
    color: white;
    padding: 16px 20px;
    border-radius: 6px;
    margin-bottom: 20px;
}

h1 {
    color: #0f172a;
    font-size: 15pt;
    font-weight: 700;
    border-bottom: 2px solid #059669;
    padding-bottom: 4px;
    margin-top: 24px;
    margin-bottom: 12px;
    page-break-after: avoid;
}

body > h1:first-of-type {
    margin-top: 0;
    font-size: 18pt;
    color: #0f172a;
}

h2 {
    color: #0f172a;
    font-size: 12pt;
    font-weight: 600;
    border-bottom: 1px solid #cbd5e1;
    padding-bottom: 3px;
    margin-top: 18px;
    margin-bottom: 10px;
    page-break-after: avoid;
}

h3 {
    color: #047857;
    font-size: 10.5pt;
    font-weight: 600;
    margin-top: 14px;
    margin-bottom: 6px;
    page-break-after: avoid;
}

h4 {
    color: #334155;
    font-size: 9.5pt;
    font-weight: 600;
    margin-top: 10px;
    margin-bottom: 4px;
    page-break-after: avoid;
}

p, ul, ol {
    margin-top: 4px;
    margin-bottom: 8px;
}

li {
    margin-bottom: 3px;
}

hr {
    border: none;
    border-top: 1px solid #e2e8f0;
    margin: 16px 0;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin: 10px 0 14px 0;
    font-size: 8.5pt;
    page-break-inside: avoid;
}

th, td {
    border: 1px solid #cbd5e1;
    padding: 5px 7px;
    text-align: left;
    vertical-align: top;
}

th {
    background-color: #f1f5f9;
    color: #0f172a;
    font-weight: 600;
}

tr:nth-child(even) {
    background-color: #f8fafc;
}

blockquote {
    border-left: 3.5px solid #059669;
    background-color: #f0fdf4;
    color: #166534;
    padding: 6px 12px;
    margin: 8px 0;
    border-radius: 0 4px 4px 0;
    font-size: 9pt;
}

pre, code {
    font-family: 'Cascadia Code', Consolas, Monaco, 'Courier New', monospace;
}

p > code, li > code, td > code {
    background-color: #f1f5f9;
    color: #0f172a;
    padding: 1px 4px;
    border-radius: 3px;
    font-size: 8.5pt;
    border: 1px solid #e2e8f0;
}

pre {
    background-color: #0f172a;
    color: #f8fafc;
    padding: 8px 12px;
    border-radius: 5px;
    font-size: 7.8pt;
    overflow-x: auto;
    page-break-inside: avoid;
    line-height: 1.35;
}

pre code {
    color: inherit;
    background: none;
    border: none;
    padding: 0;
}

img {
    max-width: 96%;
    height: auto;
    display: block;
    margin: 12px auto 4px auto;
    border: 1px solid #cbd5e1;
    border-radius: 6px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.06);
    page-break-inside: avoid;
}

em {
    color: #475569;
    font-size: 8.5pt;
}

p:has(> img) {
    page-break-inside: avoid;
    text-align: center;
}

p:has(> img) + p:has(> em) {
    text-align: center;
    margin-top: -2px;
    margin-bottom: 14px;
    page-break-after: avoid;
}
"""

full_html = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>MANI - Documento de Herramientas, Políticas y Lineamientos V2</title>
<style>
{css_content}
</style>
</head>
<body>
{html_body}
</body>
</html>"""

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(full_html)

edge_path = r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
cmd = [
    edge_path,
    '--headless',
    '--disable-gpu',
    '--no-pdf-header-footer',
    f'--print-to-pdf={pdf_path}',
    html_path
]

res = subprocess.run(cmd, capture_output=True, text=True)
print('Edge code:', res.returncode)
if os.path.exists(pdf_path):
    print('PDF generated successfully!')
    print('PDF Path:', pdf_path)
    print('PDF Size:', os.path.getsize(pdf_path), 'bytes')
    if os.path.exists(html_path):
        os.remove(html_path)
else:
    print('Error: PDF not found.')
    print(res.stderr)
