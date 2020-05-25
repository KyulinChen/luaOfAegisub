# luaOfAegisub
Aegisub's Lua plugin repository

这是用来储存我写的一些aegisub脚本的仓库，以下是关于已经放入的脚本的说明，请放入Aegisub\automation\autoload下，每次打开aegisub会自动加载，当然你也可以打开aegisub后自行进行添加：

1.DicKfTagTool.lua:
  根据字典词义切割语句，然后打上平局kf值。（需要先进行一系列操作，请先阅读文件夹里面的readme）
  
2.StyleSplitByChenKyulin.lua:
  切割选择样式的语句，根据分隔符切割语句成为N行，给单数行添加其中一种样式，给双数行添加另外一种样式，同时支持判断是否去除单双数行的ASS标签，以及单双数行所在的层级。
