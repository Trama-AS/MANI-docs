import subprocess,re
R=re.compile(r'\b(ElevatedButton|TextButton|OutlinedButton|FilledButton|TextField|TextFormField)(\.icon|\.tonal|\.tonalIcon)?\s*\(|\bCupertino\w+\s*\(')
M=re.compile(r'\b(ManiButton|ManiTextField)\b\s*[.(]')
g=lambda *a:subprocess.run(['git',*a],capture_output=True,text=True).stdout
def cuenta(rev,dir='lib/features'):
    n=m=0;arch={}
    for f in g('ls-tree','-r','--name-only',rev,dir).splitlines():
        if not f.endswith('.dart'): continue
        t='\n'.join(l for l in g('show',f'{rev}:{f}').splitlines() if not l.strip().startswith('//'))
        k=len(R.findall(t)); n+=k; m+=len(M.findall(t))
        if k: arch[f]=k
    return n,m,arch
for rev in ('7a43729','1991221','a98fa12'):
    n,m,a=cuenta(rev); print(rev,'nativos',n,'mani',m,'archivos con nativos',len(a))
toc=set(f for f in g('diff','--name-only','7a43729','a98fa12','--','lib/features').splitlines() if f.endswith('.dart'))
n,m,a=cuenta('a98fa12'); ab={f:k for f,k in a.items() if f in toc}; print('pantallas tocadas desde la regla con nativos:',len(ab),'lineas',sum(ab.values()))
for f,k in sorted(a.items(),key=lambda x:-x[1])[:8]: print('  ',k,f.split('/')[-1])
print('-- PR fusionados a develop desde 1991221')
for l in g('log','--merges','--first-parent','--format=%h|%s|%cd','--date=format:%m-%d %H:%M','1991221..origin/develop').splitlines():
    h,s,d=l.split('|',2)
    if 'develop' in s and 'from Trama-AS/develop' in s: continue
    df=g('diff',f'{h}^1',h,'--','lib'); add=[x[1:] for x in df.splitlines() if x.startswith('+') and not x.startswith('+++')]
    na=[x.strip() for x in add if R.search(x) and not x.strip().startswith('//')]; ma=sum(bool(M.search(x)) for x in add)
    pant=len([f for f in g('diff','--name-only',f'{h}^1',h,'--','lib').splitlines() if f.endswith('.dart')])
    print(h,d,s.split(' from ')[0],'lib',pant,'nativos+',len(na),'mani+',ma,na[:3] if na else '')
