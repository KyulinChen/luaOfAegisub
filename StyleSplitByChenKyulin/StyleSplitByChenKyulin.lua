
script_name = "LineSplitBySpecifySeparator"
script_description ="Use it to Split Styled Bilingual line to N lines with specific style\n将制定样式的行，根据分隔符，切割成多行，并且单双行可以指定样式.";
script_author = "ChenKyulin";
script_version = "1.0";
script_last_update_date = "2020/05/24";

require "karaskel"
require "re"

--GUI Part GUI的参数

dialog_config=
{
	[2]={class="label",x=0,y=0,label="要被分割的行的样式:"},--SelectSpiltStyle
	[3]={class="dropdown",name="SelectedSpiltStyle",x=1,y=0,width=1,height=1,items={},value=""},
	
	[4]={class="label",x=2,y=0,width=1,height=1,label="分隔符:"},--SplitCharacter
	[5]={class="edit",name="SplitCharacter",x=3,y=0,width=1,height=1,value="\\N"},
	[6]={class="checkbox",name="DeleteSplitStyleLine",x=4,y=0,width=1,height=1,label="是否删除原行",value=true},--DeleteSplitLine
	
	[7]={class="label",x=0,y=1,width=1,hegiht=1,label="分割后的单数行样式:"},--SetFirstPartStyle
	[8]={class="dropdown",name="FirstPartStyle",x=1,y=1,width=1,height=1,items={},value=""},
	[9]={class="checkbox",name="FirstPartKeepTags",x=2,y=1,width=1,height=1,label="是否保留ASS标签",value=false},--KeepASSTags
	[10]={class="label",x=3,y=1,width=1,hegiht=1,label="单数行所处在的层级:"},--SetFirstPartLayer
	[11]={class="intedit",name="FirstPartLayer",x=4,y=1,width=1,height=1,value=1},
	
	[12]={class="label",x=0,y=2,width=1,hegiht=1,label="分割后的双数行样式:"},--SetSecondPartStyle
	[13]={class="dropdown",name="SecondPartStyle",x=1,y=2,width=1,height=1,items={},value=""},
	[14]={class="checkbox",name="SecondPartKeepTags",x=2,y=2,width=1,height=1,label="是否保留ASS标签",value=false},	--KeepASSTags
	[15]={class="label",x=3,y=2,width=1,hegiht=1,label="双数行所处在的层级:"},--SetSecondPartLayer
	[16]={class="intedit",name="SecondPartLayer",x=4,y=2,width=1,height=1,value=2},

	[17]={class="label",x=0,y=3,width=1,hegiht=1,label="每一行双语字幕的时长(单位毫秒):"},--SetSecondPartStyle
	[18]={class="edit",name="IntervalTime",x=1,y=3,width=1,height=1,value="5000"},
}


SplitIdx = 3;
FirstPartIdx = 8;
SecondPartIdx = 13;

--设置GUI的相关参数
function SetDropItem(subs,sel)
   
   meta, styles = karaskel.collect_head(subs);
   
   dialog_config[ SplitIdx ].items={};
   
   --1.把所有样式的名字都放进去selectSpiltStyle这个dropdown里面的名为items的table里面
   for i=1,styles.n,1 do
      table.insert(dialog_config[ SplitIdx ].items,styles[i].name);
   end
   
   --2.复制selectSpiltStyle的items table给FirstPartStyle,SecondPartStyle的items table
   -- 并且设置默认值(FirstPartStyle的value,SecondPartStyle的value)为第一个值
   dialog_config[ FirstPartIdx ].items = table.copy(dialog_config[ SplitIdx ].items );
   dialog_config[ FirstPartIdx ].value = dialog_config[ FirstPartIdx ].items[1];
   
   dialog_config[ SecondPartIdx ].items = table.copy(dialog_config[ SplitIdx ].items );
   dialog_config[ SecondPartIdx ].value = dialog_config[ SecondPartIdx ].items[1]; 
   
   
   --set default by maximum line style
   

   --3.创建名为count的table，key为各个样式的name，初始化value都为0
   --准备统计使用各个样式的值
   local count={};
   for i=1,styles.n,1 do
      count[ styles[i].name ] = 0;
   end   
   
   --4.统计各个样式的使用行数
   for i=1,#subs,1 do
      local line = subs[i];
	  if line.class == "dialogue" then
	     count[ line.style ] = count[ line.style ]+1;
	  end
   end
   
   --5.找出最多行使用的样式
   local MaxLine=0;
   local MaxLineStyleName = nil;
   for i=1,styles.n,1 do
      local tname  = styles[i].name;
	  local tcount = count[ tname ];
      if tcount > MaxLine then
	     MaxLine = tcount;
		 MaxLineStyleName = tname;
	  end
   end
   
   --6.selectSpiltStyle的默认值是最多行使用的样式
   if MaxLineStyleName~=nil then
      dialog_config[ SplitIdx ].value = MaxLineStyleName;
   end
   
end


--替换违法字符
function TextTagsFilter(Text)
   return Text:gsub("{[^}]+}", "");
end

--根据pPattern切割文本
function Split(pString, pPattern)
   local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(Table,cap)
      end
      last_end = e+1
      s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
      cap = pString:sub(last_end)
      table.insert(Table, cap)
   end
   return Table
end

-----获取table的长度
function TableLeng(t)
	local leng=0
	for k, v in pairs(t) do
	  leng=leng+1
	end
	return leng;
end


function SplitLine(subs,sel)
	--1.展示GUI
   buttons,results =aegisub.dialog.display(dialog_config,{"OK","Cancel"});	

   --2如果按下了OK按钮，则
   if buttons=="OK" then
		--SelectedSpiltStyle选择的样式：选择要被拆分的行的样式
	   local SpecificSplitStyle = results["SelectedSpiltStyle"];
	   --FirstPartStyle选择的样式：分割后第一部分的样式
	   local FirstSetStyle = results["FirstPartStyle"]; 
	   --SecondPartStyle选择的样式：分割后第二部分的样式
	   local SecondSetStyle = results["SecondPartStyle"];
	   --SplitCharacter选择的样式：分割的字符
	   local SplitCharacter = results["SplitCharacter"];
	   --FirstPartKeepTags是否选择了：是否保留第一种样式的ASS标签
	   local FirstPartKeepTags  = results["FirstPartKeepTags"];
	   --SecondPartKeepTags是否选择了：是否保留第二种样式的ASS标签
	   local SecondPartKeepTags = results["SecondPartKeepTags"]; 
	   --FirstPartLayer
	   local FirstPartLayer = results["FirstPartLayer"];
	   --SecondPartLayer
	   local SecondPartLayer = results["SecondPartLayer"];
	   --DeleteSplitStyleLine是否选择了：是否删除要被拆分的样式行
	   local DeleteSplitStyleLine = results["DeleteSplitStyleLine"];

	   --DeleteSplitStyleLine是否选择了：是否删除要被拆分的样式行
	   local IntervalTime = results["IntervalTime"];

	   --3.统计要被拆分的特定样式的行数
	   local TotalProcessLineNum = 0;
	   for i=1,#subs,1 do
	       local line = subs[i];
		    if line.class=="dialogue" and line.style==SpecificSplitStyle then
			    TotalProcessLineNum = TotalProcessLineNum  + 1;
			end
	   end
	   
	   --4.拆分成两行添加各自样式和文本并且放回原来的subs
	   local CurrentProcessLineNum = 0;
       local SpecificStyleIndex={};
	   
	   for i=1,#subs,1 do
		  local line = subs[i];
		  if line.class=="dialogue" and line.style==SpecificSplitStyle then
		       
               CurrentProcessLineNum = CurrentProcessLineNum + 1;
               
               --储存要被删除的行号
			   SpecificStyleIndex[#SpecificStyleIndex + 1] = i;
			   
			   --切割当前行，并且统计切割后的部分
			   local SplitTextTable = Split(line.text,SplitCharacter);
			   local lengOfSplitTextTable = TableLeng(SplitTextTable);

			   --用于储存单数行
			   local FirstTable = {};

			   --用于出处双数行
			   local SecondTable = {};

			   for j=1,lengOfSplitTextTable,1 do
					--单数行
					if j%2==1 then
						local oddLine = SplitTextTable[j];
						if oddLine~=nil then
							if FirstPartKeepTags == false then
								oddLine = TextTagsFilter(oddLine);
							end
							local NewLine = table.copy(line);
					 		NewLine.text = oddLine;
					 		NewLine.style = FirstSetStyle;
							NewLine.layer = FirstPartLayer;

							NewLine.start_time = (j-1)/2*IntervalTime ;
							NewLine.end_time = (j+1)/2*IntervalTime;

							--subs.append(NewLine);
							table.insert(FirstTable,NewLine);
			   			end
					end
					--双数行
					if j%2==0 then
						local evenLine = SplitTextTable[j];
						if evenLine~=nil then
							if SecondPartKeepTags == false then
								evenLine = TextTagsFilter(evenLine);
							end
							local NewLine = table.copy(line);
					 		NewLine.text = evenLine;
					 		NewLine.style = SecondSetStyle;
							NewLine.layer = SecondPartLayer;
							 
							NewLine.start_time = (j-2)/2*IntervalTime;
							NewLine.end_time = j/2*IntervalTime;
							--subs.append(NewLine);
							table.insert(SecondTable,NewLine);
			   			end
					end

					--用于每次插入完一句双语(即两句话后，互换位置，视觉上呈现按顺序排列)
					-- if j%2==0 then
					-- 	local temp = subs[#subs-1];
					-- 	subs[#subs-1] = subs[#subs];
					-- 	subs[#subs] = temp;
					-- end
			   end

			   
			    --先插入双数行，再插入单数行
				local lengOfSecondTable = TableLeng(SecondTable);
				for n=1,lengOfSecondTable,1 do
					subs.append(SecondTable[n]);
				end

				local lengOfFirstTable = TableLeng(FirstTable);
				for m=1,lengOfFirstTable,1 do
					subs.append(FirstTable[m]);
				end

		    --    local FirstText = SplitTextTable[1];
			--    local SecondText = SplitTextTable[2];
			--    if FirstText~=nil then
			--       if FirstPartKeepTags == false then
			-- 	     FirstText = TextTagsFilter(FirstText);
			-- 	     end
			-- 	     local NewLine = table.copy(line);
			-- 		 NewLine.text = FirstText;
			-- 		 NewLine.style = FirstSetStyle;
			-- 		 NewLine.layer = FirstPartLayer;
			-- 		 subs.append(NewLine);
			--    end
			   
			--    if SecondText~=nil then
			--      if SecondPartKeepTags == false then
			-- 	    SecondText = TextTagsFilter(SecondText);
			-- 	 end
			-- 		 local NewLine = table.copy(line);
			-- 		 NewLine.text = SecondText;
			-- 		 NewLine.style = SecondSetStyle;
			-- 		 NewLine.layer = SecondPartLayer;
			-- 		 subs.append(NewLine);		   
			--    end
		  end
		  
          --每次处理完一行选中对应样式文本，更新处理进度条
		  aegisub.progress.set(CurrentProcessLineNum/TotalProcessLineNum);
	   end

	   --5.如果选择了要删除被切割的特定样式行，则去删除特定样式的行
	   if DeleteSplitStyleLine == true then
	      subs.delete(unpack(SpecificStyleIndex));
	   end
   end
end

function script_main(subs,sel)
    SetDropItem(subs,sel);
	SplitLine(subs,sel);
end

aegisub.register_macro(script_name, script_description, script_main)

