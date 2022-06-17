
# +--------------------
# |
# | Random Death Messages
# |
# | Provides random messages when players expire in an unfortunate manner.
# |
# +----------------------
#
# @author GoMinecraft ( Discord: BrainFailures#1421 )
# @date 2019/12/27
# @denizen-build ALWAYS USE THE LATEST @ https://ci.citizensnpcs.co/job/Denizen/
# @script-version 1.3.7
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

RDMVersion:
  type: data
  version: 1.3.7

RDMInit:
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

  - if <yaml.list.contains_all_text[rdm_config|rdm_pvp|rdm_mobs|rdm_env|rdm_mythicmobs]>:
    - announce to_console "[RandomDeathMessages] Loaded all config files successfully. This does not mean there were no syntax errors."
    - flag server failedLoad:!
  - else:
    - announce to_console "[RandomDeathMessages] One or more config files failed to load. Please check your console log."
    - flag server failedLoad

RDMCommand:
  type: command
  debug: false
  name: randomdeathmessages
  aliases:
  - rdm
  description: Show what version of RandomDeathMessages is installed
  usage: /randomdeathmessages <&lt>version|reload<&gt>
  permission: randomdeathmessages.rdm
  permission message: <red>Sorry, <player.name>, you do not have permission to run that command.
  tab complete:
  - if <context.args.size> < 1:
    - determine <list[reload|version]>
  - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
    - determine <list[reload|version].filter[starts_with[<context.args.get[1]>]]>
  script:
  - choose <context.args.get[1]||version>:
    - case version:
      - narrate "<red>RandomDeathMessages <green>v<script[rdm_version].data_key[version]>"
    - case reload:
      - inject rdm_init
      - narrate "<green>RandomDeathMessages has been reloaded."
    - default:
      - narrate "<red>Unknown argument: <gold><context.args.get[1]>"

RDMSuicideCommand:
  type: command
  debug: false
  description: Suicide command.
  usage: /suicide
  name: suicide
  aliases:
  - dsuicide
  - esuicide
  script:
  - hurt 500 <player>

# And here be the guts
RandomDeathMessages:
  type: world
  debug: false
  events:
    on reload scripts:
      - inject RDMInit

    on server start:
      - inject RDMInit

    on suicide command:
      - flag player suicide duration:1t

    on dsuicide command:
      - flag player suicide duration:1t

    on esuicide command:
      - flag player suicide duration:1t

    on player death:
    # If it failed to load, we just show the default MC message.
    - if <server.has_flag[failedLoad]>:
      - stop

    # Set our victim placeholder for the yaml files.
    - define victim:<player.name>

    # This is inelegant, but how it has to work, it seems.
    - if <player.flag[suicide]||false> || <context.damager||null> == <player>:
      - determine <yaml[rdm_env].read[SUICIDE].random.parsed>

    # Begin PVP
    - if <context.damager.entity_type.contains_any_text[WOLF|PLAYER]||false>:
      - if <context.damager.entity_type> == WOLF && <context.damager.is_tamed||false>:
        - define killer:<context.damager.owner.name>
        - determine <yaml[rdm_pvp].read[WOLF].random.parsed>

      - define killer:<context.damager.name>
      - define weapon:<context.damager.item_in_hand.formatted>

      - if <context.cause> == PROJECTILE:
        - determine <yaml[rdm_pvp].read[RANGED].random.parsed>

      - if <context.damager.entity_type> == PLAYER:
        - if <[weapon]> == nothing:
          - determine <yaml[rdm_pvp].read[FISTS].random.parsed>

        - determine <yaml[rdm_pvp].read[WEAPON].random.parsed>
    # End PVP

    # Begin MythicMobs
    - if <server.plugins.contains_all_text[Depenizen|MythicMobs]> && <context.damager.is_mythicmob||false>:
      - if <yaml[rdm_mythicmobs].read[<context.damager.mythicmob.internal_name>]||null> == null:
        - announce to_console "[RandomDeathMessages] No key found for <context.damager.mythicmob.internal_name> - (Mythic Mob)"
        - determine <context.message>
      - determine <yaml[rdm_mythicmobs].read[<context.damager.mythicmob.internal_name>].random.parsed>
    # End MythicMobs

    # Begin MC Mobs
    - if <context.cause||null> == WITHER:
      - determine <yaml[rdm_mobs].read[WITHER_SKELETON].random.parsed>

    - if <context.cause> == ENTITY_ATTACK || <context.damager.entity_type.contains_any_text[CREEPER|PILLAGER|SHULKER|SKELETON|STRAY|]||false>:
      - if <yaml[rdm_mobs].read[<context.damager.entity_type>]||null> == null:
        - announce to_console "[RandomDeathMessages] No key found for <context.damager.entity_type> - (Regular MC Monster)"
      - determine <yaml[rdm_mobs].read[<context.damager.entity_type>].random.parsed>
    # End MC Mobs

    # Begin "Environment"
    - if <context.cause||null> == FIRE_TICK || <context.cause||null> == FIRE:
      - determine <yaml[rdm_env].read[FIRE].random.parsed>

    # Catch TNT
    - if <context.damager.entity_type||null> == PRIMED_TNT:
      - determine <yaml[rdm_env].read[PRIMED_TNT].random.parsed>

    - if <yaml[rdm_env].read[<context.cause>]||null> == null:
      - announce to_console "[RandomDeathMessages] No key found for <context.cause> - (Environment - possibly)"
      - determine <context.message>

    - determine <yaml[rdm_env].read[<context.cause>].random.parsed>
    # End Environment
