# RandomDeathMessages

Denizen script to replace death messages with random, saltier messages.

----

## Requirements

* [Spigot](https://www.spigotmc.org/)
* [Denizen](https://ci.citizensnpcs.co/job/Denizen/) | [Denizen Development](https://ci.citizensnpcs.co/job/Denizen_Developmental/)

If you are using [MythicMobs](https://www.mythicmobs.net/index.php?pages/download/), you also need [Depenizen](https://ci.citizensnpcs.co/job/Depenizen/). You should probably get Depenizen anyway.

## Installation
... (of RandomDeathMessages, not the above requirements - that's your problem!)

* Download [RandomDeathMessages](https://gominecraft.com/files/RandomDeathMessages.zip)
* Unpack the contents directly into **plugins/**

If the server is already running, simply execute this in-game:

~~~
/ex reload scripts
~~~

Otherwise, start the server up.

That's it, You're done.

You may modify the yaml files under plugins/RandomDeathMessages/language/en_us/ at will. The format should be fairly obvious.

If you would like to translate it to another language, I recommend making a new directory inside of /languages/, copying the existing yml files to the new location and modifying them there.

You can edit **plugins/RandomDeathMessages/config.yml** to point to the new language directory.

Example:

If you made a new directory called gb_gb in plugins/RandomDeathMessages/language/:

~~~
language: gb_gb
~~~
