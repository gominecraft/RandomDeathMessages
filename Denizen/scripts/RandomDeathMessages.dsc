#
#
# Random Death Messages
#
# Provides random messages when players expire in an unfortunate manner.
#
# author  : GoMinecraft ( Discord: GoMinecraft#1421 )
# version : 0.1
#
# Recommendation(s):
# * Install Depenizen, required if you want custom death messages for MythicMobs.
#
# enable_debug_messages is NOT the same as Denizen debug mode.
#

rdm_config:
  type: yaml data
  # Begin config
  enable_debug_messages: true
  # End config

# ---- Don't edit below here unless you know what you're doing.
# ---- I definitely don't know what I'm doing.

rdm_init:
  type: task
  debug: true
  script:
  - flag server rdm_missing_file:false
  # Load our files..
  - if <server.has_file[../RandomDeathMessages/mobs.yml]>:
    - ~yaml load:../RandomDeathMessages/mobs.yml id:rdm_mobs
  - else:
    - debug log "Unable to load plugins/RandomDeathMessages/mobs.yml - File is missing!"
    - flag server rdm_missing_file:true

  - if <server.has_file[../RandomDeathMessages/environment.yml]>:
    - ~yaml load:../RandomDeathMessages/environment.yml id:rdm_env
  - else:
    - debug log "Unable to load plugins/RandomDeathMessages/environment.yml - File is missing!"
    - flag server rdm_missing_file:true

  - if <server.has_file[../RandomDeathMessages/pvp.yml]>:
    - ~yaml load:../RandomDeathMessages/pvp.yml id:rdm_pvp
  - else:
    - debug log "Unable to load plugins/RandomDeathMessages/pvp.yml - File is missing!"
    - flag server rdm_missing_file:true

  - if <server.has_file[../RandomDeathMessages/mythicmobs.yml]>:
    - ~yaml load:../RandomDeathMessages/mythicmobs.yml id:rdm_mythicmobs
  - else:
    - debug log "Unable to load plugins//RandomDeathMessages/mobs.yml - File is missing!"
    - flag server rdm_missing_file:true

  - if <server.flag[rdm_missing_file]> == true:
    - narrate "<red>One or more expected files are missing. RandomDeathMessages will not be enabled."


RandomDeathMessages:
  type: world
  debug: true
  events:
    on server start:
      - debug log "Now running rdm_init.after startup.."
      - inject <script[rdm_init]>

    on reload scripts:
      - debug log "Now running rdm_init.after reload.."
      - inject <script[rdm_init]>

    on player death:

    # If debug messages is on, throw some trash into the log.
    - if <script[rdm_config].yaml_key[enable_debug_messages]> == true:
      - debug log "Cause: <context.cause>"
      - debug log "Entity: <context.damager.entity_type>"
      - if <context.damager.is_mythicmob> == true:
        - debug log "Is Mythic Mob: context.damager.is_mythicmob"
        - debug log "MythicMob Internal Name: <context.damager.mythicmob.internal_name>"

    - if <server.flag[rdm_missing_file]> == true:
      - determine <context.message>

    # Begin PVP
    - if <context.damager.entity_type> == PLAYER:

      # Set a useful var, only used in the PVP context.
      - define killer:<context.damager.name>
      - define weapon:<context.damager.item_in_hand.formatted>

      # Did we get hit by an arrow?
      - if <context.cause> == PROJECTILE:
        - determine <yaml[rdm_pvp].list_keys[RANGED].random.replace[!player].with[<player.name>].replace[!killer].with[<[killer]>].parse_color>

      # Melee, empty hand
      - if <[weapon]> == "nothing":
        - determine <yaml[rdm_pvp].list_keys[FISTS].random.replace[!player].with[<player.name>].replace[!killer].with[<[killer]>].parse_color>

      # Melee, something in-hand.
      - determine <yaml[rdm_pvp].list_keys[WEAPON].random.replace[!player].with[<player.name>].replace[!killer].with[<[killer]>].replace[!weapon].with[<[weapon]>].parse_color>
    # End PVP

    # Begin MythicMobs
    - if <server.list_plugins.contains_text[Depenizen]>:
      - if <context.damager.is_mythicmob>:
        - determine <yaml[rdm_mythicmobs].list_keys[<context.damager.mythicmob.internal_name>].random.replace[!player].with[<player.name>].parse_color>
    # End MythicMobs

    # Begin MC Mobs
    - if <context.cause> == ENTITY_ATTACK || <context.damager.entity_type> == SKELETON:
      - determine <yaml[rdm_mobs].list_keys[<context.damager.entity_type>].random.replace[!player].with[<player.name>].parse_color>
    # End MC Mobs

    # Begin Environment - this needs work..
    - if <context.cause> != ENTITY_ATTACK:
      - determine <yaml[rdm_env].list_keys[<context.cause>].random.replace[!player].with[<player.name>].parse_color>
    # End Environment
