# Czech-Localization-for-WoW-1.12.1
Modification/Continuation of work on the Czech localization for 1.12.1 done by the community at [wowpreklad.zdechov.net](http://wowpreklad.zdechov.net/).

The main aim of this project is to allow Czech players who are new at the game to jump into 1.12.1 servers and have an easier time getting used to how their spells/talents work, while also avoiding communication problems that arise from Blizzard's official translations of the games.

Most private servers allow connections from any 1.12.1 client, which means that players cooperating together might run into communication challenges. For example, in voice chats, a Russian player might not know the English name of a buff that he needs from his English speaking raid mate. This is because spell names, item names, and talent names are all translated in the various official localizations.

# What will be translated?
To avoid adding another language to this Tower of Babel, I have decided against translating some parts of the game. Basically, only things that are visible to the player will be translated. Anything that would need to be communicated to another player will retain the English name.

### Some examples of things we will **not** translate:
* Spell Names
* Spell School Names
* Item Names
* Stats (Agility, Stamina, Crit, Hit, etc)
* Quest Names
* Zones/Dungeons/Raids
* Some class resource names (mana, rage only)

### Some examples of things we will translate:
* UI elements
* Emotes
* Quest texts/objectives
* Spell and Spell Aura Descriptions

## How to build this patch manually with your own changes
You will need [Ladik's MPQ Editor](https://www.zezula.net/en/mpq/download.html) and [WDBXEditor](https://github.com/WowDevTools/WDBXEditor).

Use WDBXEditor to edit any of the dbc files in the patch in the dbfilesclient folder. Everything else can be edited using your text editor of choice.

Once your changes are complete, you need to use Ladik's MPQ Editor to build the patch.

## Where can I use this patch?
This patch should be fine on any stock 1.12.1 vanilla server without any issues. However, it **IS** a game file mod that might not be allowed on some projects. Always ask your server's admins if it is alright.

## What about custom 1.12.1 servers?
It can work, but you will need to build the patch yourself. It also depends on how heavily modified the server is. A server with minimal changes to spells (think % changes that variables can show automatically - not major spell reworks) should be easy to work with. You would simply export their spell.dbc to a CSV file and then run the included script to apply our localization to the CSV. Then re-import the CSV file. You could even add your own translations for custom spells if you want (but please don't open PRs to apply them here. We only support stock 1.12.1 localization).

If the server is super heavily modified (like Turtle-WoW), you would need to carefully examine their GLUE changes and copy our localizations over their strings.

## How to use this patch?
Download the patch-Y from the release section and place it in your Wow1.12.1\Data folder. As this patch translates UI elements, you will also need to use a .exe file that has been patched to support modded GLUE files.
This .exe has a different hash than the standard .exe, so some severs might not let you connect. In that case, you should delete the interface folder inside the patch. This means the UI will be in English again, but spells/emotes/quests should still be in Czech. Or ask your server admin very nicely to whitelist the patched .exe hash.

This patch should be loaded after all other patches. The 1.12.1 client loads patches numerically and then alphabetically, so feel free to rename it from patch-Y to whatever works for your load order.

## How is this done?
The community at [wowpreklad.zdechov.net](http://wowpreklad.zdechov.net/) already made some great progress on translating UI stuff, emotes, and quests. However, a lot of spell descriptions were still missing (over 20 thousand)

I used [Ladik's MPQ Editor](https://www.zezula.net/en/mpq/download.html) to open the original project patch. Utilizing [WDBXEditor](https://github.com/WowDevTools/WDBXEditor), we can export the spell.dbc made by the original project to a CSV file. Using some python scripts, I filtered out all of the already translated spell descriptions and then used machine translation on the leftover untranslated English spell/aura descriptions. I used another script to insert these back into the CSV file and re-imported it into the spell.dbc

# Potential Issues
I am not a native Czech speaker - I am simply a fan of the language. Although I am great at this language, mistakes happen. Especially when the spell descriptions can take on a fantasy-style tone which I don't know how to replicate authentically in Czech.

### Machine Translation issues

* Some words are not translated consistently. Warrior Rage was translated sometimes as "Vztek" and sometimes as "Zuřivost".
* Sometimes descriptions of the same spell had different ranks translated differently. They are usually both correct, but consistency is desired.
* References to spell names in the descriptions were translated. This conflicts with our aim to keep spell names in English. This is super visible on Paladins with the [Forbearance debuff](https://www.wowhead.com/classic/spell=25771/forbearance). Divine Shield should stay as Divine Shield, not "Božský štít".
* Crafting Spells/Recipes have their spell name in English, but the descriptions have the produced item names in Czech. The [Pattern: White Wedding Dress](https://www.wowhead.com/classic/item=10325/pattern-white-wedding-dress) has the spell description "Naučí vás vyrobit bílé svatební šaty" instead of "Naučí vás vyrobit White Wedding Dress".
* General linguistic inconsistencies. Sometimes it using Ty form, sometimes Vy form. Somtimes "Naučí vás" and sometimes "Učí tě".

## What can I do to help?
The best help would be to just play the game with the patch and note down any issues you see. Feel free to create an Issue on the repo with the relevant details (spell ID from [Wowhead](https://www.wowhead.com/classic) or [Classic DB](https://classicdb.ch/) and the correct way to translate the spell would be much appreciated.).
