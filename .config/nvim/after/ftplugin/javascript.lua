vim.cmd(
    [[setlocal foldmethod=expr foldexpr=getline(v:lnum)=~'^\\s*/\\*\\*'?'>1':getline(v:lnum)=~'^\\s*\\*/'?'<1':'=' foldlevel=0]]
)
