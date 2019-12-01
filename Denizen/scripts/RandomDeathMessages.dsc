
# +--------------------
# |
# | Random Death Messages
# |
# | Provides random messages when players expire in an unfortunate manner.
# |
# +----------------------
#
# @author GoMinecraft ( Discord: GoMinecraft#1421 )
# @date 2019/11/27
# @denizen-build REL-1696
# @script-version 1.2.3
#
# Usage:
# /rdm (version) - Shows the version
# /rdm reload - Reloads the config.yml and related language files.
#
# Recommendation(s):
# * Install Depenizen, required if you want custom death messages for MythicMobs.
#   * If you don't, you get the death messages for the underlying base mob.

# ---- Don't edit below here unless you know what you're doing.
# ---- I definitely don't know what I'm doing.

rdm_version:
  type: yaml data
  version: 1.2.3

  # Yes, this is a noisy mess. Will clean up later.
rdm_init:
  type: task
  debug: false
  script:

  - if <server.has_file[../RandomDeathMessages/config.yml]>:
    - ~yaml load:../RandomDeathMessages/config.yml id:rdm_config
    - announce to_console "[RandomDeathMessages] Loaded config.yml"
  - else:
    - announce to_console "Unables to load plugins/RandomDeathMessages/config.yml"

  - if <server.has_file[../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/mobs.yml]>:
    - ~yaml load:../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/mobs.yml id:rdm_mobs
    - announce to_console "[RandomDeathMessages] Loaded <yaml[rdm_config].read[language]>/mobs.yml"
  - else:
    - announce to_console "Unable to load plugins/RandomDeathMessages/language/<yaml[rdm_config].read[language]>/mobs.yml - File is missing!"

  - if <server.has_file[../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/environment.yml]>:
    - ~yaml load:../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/environment.yml id:rdm_env
    - announce to_console "[RandomDeathMessages] Loaded <yaml[rdm_config].read[language]>/environment.yml"
  - else:
    - announce to_console "Unable to load plugins/RandomDeathMessages/language/<yaml[rdm_config].read[language]>/environment.yml - File is missing!"

  - if <server.has_file[../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/pvp.yml]>:
    - ~yaml load:../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/pvp.yml id:rdm_pvp
    - announce to_console "[RandomDeathMessages] Loaded <yaml[rdm_config].read[language]>/pvp.yml"
  - else:
    - announce to_console "Unable to load plugins/RandomDeathMessages/language/<yaml[rdm_config].read[language]>/pvp.yml - File is missing!"

  - if <server.has_file[../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/mythicmobs.yml]>:
    - ~yaml load:../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/mythicmobs.yml id:rdm_mythicmobs
    - announce to_console "[RandomDeathMessages] Loaded <yaml[rdm_config].read[language]>/mythicmobs.yml"
  - else:
    - announce to_console "Unable to load plugins/RandomDeathMessages/language/<yaml[rdm_config].read[language]>/mobs.yml - File is missing!"

  - if <yaml.list.contains_all[rdm_config|rdm_pvp|rdm_mobs|rdm_env|rdm_mythicmobs]>:
    - narrate "<green>Loaded all RandomDeathMessage config files successfully. This does not mean there were no syntax errors."
    - flag server failedLoad:false
  - else:
    - narrate "<red>One or more config files failed to load. Please check your console log."
    - flag server failedLoad:true

rdm_cmd:
  type: command
  debug: false
  name: randomdeathmessages
  aliases:
  - rdm
  description: Show what version of RandomDeathMessages is installed
  usage: /randomdeathmessages <&lt>version|reload<&gt>
  permission: randomdeathmessages.rdm
  permission message: <red>Sorry, <player.name>, you do not have permission to run that command.
  script:
  - if <context.args.size> == 0 || <context.args.get[1]||null> == version:
    - narrate "<red>RandomDeathMessages <green>v<script[rdm_version].yaml_key[version]>"
  - else if <context.args.get[1]> == "reload":
    - inject rdm_init
    - narrate "<green>RandomDeathMessages has been reloaded."
  - else:
    - narrate "<red>Unknown command: <gold><context.args.get[1]>"

# And here be the guts
RandomDeathMessages:
  type: world
  debug: false
  events:
    on reload scripts:
      - inject rdm_init

    on server start:
      - inject rdm_init

    on player death:
    - if <server.flag[failedLoad]>:
      - stop

    - define victim:<player.name>

    # Begin PVP
    - if <context.damager.entity_type.contains_any_text[WOLF|PLAYER]||false>:
      - if <context.damager.entity_type> == WOLF && <context.damager.is_tamed||false>:
        - define killer:<context.damager.owner.name>
        - determine <yaml[rdm_pvp].read[WOLF].random.parsed>

      # Set a useful var, only used in the PVP context.
      - define killer:<context.damager.name>
      - define weapon:<context.damager.item_in_hand.formatted>

      # Did we get hit by an arrow?
      - if <context.cause> == PROJECTILE:
        - determine <yaml[rdm_pvp].read[RANGED].random.parsed>

      # Melee, empty hand
      - if <context.damager.entity_type> == PLAYER:
        - if <[weapon]> == nothing:
          - determine <yaml[rdm_pvp].read[FISTS].random.parsed>

        # Melee, something in-hand.
        - determine <yaml[rdm_pvp].read[WEAPON].random.parsed>
    # If nothing in here fires, it was an untamed wolf that muirdered the player.
    # End PVP

    # Begin MythicMobs
    - if <server.list_plugins.contains_all[Depenizen|MythicMobs]> && <context.damager.is_mythicmob||false>:
        - determine <yaml[rdm_mythicmobs].read[<context.damager.mythicmob.internal_name>].random.parsed>
    # End MythicMobs

    # Begin MC Mobs
    - if <context.cause> == ENTITY_ATTACK || <context.damager.entity_type.contains_any[SKELETON|PILLAGER]||false>:
      - determine <yaml[rdm_mobs].read[<context.damager.entity_type>].random.parsed>
    # End MC Mobs

    # Begin Environment - this needs work..
    - determine <yaml[rdm_env].read[<context.cause>].random.parsed>
    # End Environment
