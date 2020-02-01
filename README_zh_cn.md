# RandomDeathMessages

翻译/Translation: Github@[CodingEric](https://github.com/codingeric)

一个Denizen脚本，用于以随机和有内味的文本替换Minecraft的默认死亡消息。

----

## 前置要求

* [PaperMC核心](https://papermc.io/) 或者 [Spigot核心](https://www.spigotmc.org/)
* [Denizen插件](https://ci.citizensnpcs.co/job/Denizen/) 或者 [Denizen插件开发版](https://ci.citizensnpcs.co/job/Denizen_Developmental/)

如果你使用 [MythicMobs神话怪物插件](https://www.mythicmobs.net/index.php?pages/download/)， 你还需要安装 [Depenizen](https://ci.citizensnpcs.co/job/Depenizen/)。

## 安装
（这里只列出RandomDeathMessages的安装方法，至于前置要求里的插件安装——那就是你的问题了！）

* 下载 [RandomDeathMessages](https://gominecraft.com/files/RandomDeathMessages.zip)
* 解包，然后把压缩包中的内容直接复制到 **plugins/** 文件夹
* 对于中国用户，请把**plugins/RandomDeathMessages/config.yml**中的language修改为zh_cn。

如果服务器正在运行，请直接执行（如果你把Denizen插件和本插件同时安装，那么执行以下命令无效，请直接重启服务器）：

~~~
/ex reload scripts
~~~

否则，直接启动服务器。

搞定。

## 配置

你可以根据自身需要编辑 **plugins/RandomDeathMessages/language/zh_cn/** 文件。书写格式应该很清楚了。

如果你想要把插件翻译成其他语言，我建议在 **plugins/RandomDeathMessages/languages/** 里建立新的文件夹，复制其他语言的yml文件到新文件夹中，然后进行编辑。

还有，你可以通过提交PR协助插件的翻译。

通过编辑 **plugins/RandomDeathMessages/config.yml** 的内容来更改插件的语言。

例子：

如果你在plugins/RandomDeathMessages/language/文件夹中创建了gb_gb翻译，并且想应用看看效果，你应该在config.yml中这样设置：

~~~
language: gb_gb
~~~
