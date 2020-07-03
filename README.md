# luaOfAegisub
Aegisub's Lua plugin repository

这是用来储存我写的一些aegisub脚本的仓库，以下是关于已经放入的脚本的说明，请放入Aegisub\automation\autoload下，每次打开aegisub会自动加载，当然你也可以打开aegisub后自行进行添加：

1.DicKfTagTool.lua:
  根据字典词义切割语句，然后打上平局kf值。（需要先进行一系列操作，请先阅读文件夹里面的readme）
  
  示例：
  
  ![image](https://github.com/KyulinChen/luaOfAegisub/blob/master/DemoPic/demo1.gif)
  
2.StyleSplitByChenKyulin.lua:
  主要用于双语字幕处理，只需要把双语放进第一行然后调用程序即可简单地分割译文和原文，包括但不限于：
  
  1)完全分离双语;
  
  示例：
  
  ![image](https://github.com/KyulinChen/luaOfAegisub/blob/master/DemoPic/demo2-1.gif)
  
  2)隔一个分隔符分离文本等等（就每一行轴一句原文+一句译文）;
  
  示例：
  
  ![image](https://github.com/KyulinChen/luaOfAegisub/blob/master/DemoPic/demo2-2.gif)
  
  3)切割选择样式的语句，根据分隔符切割语句成为N行，给单数行添加其中一种样式，给双数行添加另外一种样式;
  
  4)同时支持判断是否去除单双数行的ASS标签，以及单双数行所在的层级等等。（功能越加越多，码字有空再进行，欢迎使用）;
  
  5)是否分割后反转单双行;
  
  示例1 未反转单双行：
  
  ![image](https://github.com/KyulinChen/luaOfAegisub/blob/master/DemoPic/demo2-4.gif)
  
  示例2 反转单双行：
  
  ![image](https://github.com/KyulinChen/luaOfAegisub/blob/master/DemoPic/demo2-3.gif)
  
3.UseInputStringToSplitSentence.lua

  根据字典词义切割语句，然后在切割语句的中间加入你输入的 ASS代码字符串。（需要先进行一系列操作，请先阅读文件夹里面的readme）
  
   示例：
   
  ![image](https://github.com/KyulinChen/luaOfAegisub/blob/master/DemoPic/demo3.gif)
  
