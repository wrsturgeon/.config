ctx:
ctx.pkgs.writeTextFile "kitty.conf" ''
  include ${ctx.pkgs.kitty-themes}/themes/GitHub_Dark.conf

  font_family Iosevka Custom Light
  bold_font Iosevka Custom Extrabold
  italic_font Iosevka Custom Light Italic
  bold_italic_font Iosevka Custom Extrabold Italic

  font_size 13

  disable_ligatures always
''
