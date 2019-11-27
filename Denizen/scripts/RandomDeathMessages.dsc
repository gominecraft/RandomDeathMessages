#
# Random Death Messages
#
# Provides random messages when players expire in an unfortunate manner.
#
# author  : GoMinecraft ( Discord: GoMinecraft#1421 )
# version : 1.0.0
#
# Recommendation(s):
# * Install Depenizen, required if you want custom death messages for MythicMobs.
#

# ---- Don't edit below here unless you know what you're doing.
# ---- I definitely don't know what I'm doing.

rdm_init:
  type: task
  debug: false
  script:
  - flag server rdm_missing_file:false

  - if <server.has_file[../RandomDeathMessages/config.yml]>:
    - ~yaml load:../RandomDeathMessages/config.yml id:rdm_config
  - else:
    - debug log "Unables to load plugins/RandomDeathMessages/config.yml"
    - flag server rdm_missing_file:true

  - if <server.has_file[../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/mobs.yml]>:
    - ~yaml load:../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/mobs.yml id:rdm_mobs
  - else:
    - debug log "Unable to load plugins/RandomDeathMessages/language/<yaml[rdm_config].read[language]>/mobs.yml - File is missing!"
    - flag server rdm_missing_file:true

  - if <server.has_file[../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/environment.yml]>:
    - ~yaml load:../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/environment.yml id:rdm_env
  - else:
    - debug log "Unable to load plugins/RandomDeathMessages/language/<yaml[rdm_config].read[language]>/environment.yml - File is missing!"
    - flag server rdm_missing_file:true

  - if <server.has_file[../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/pvp.yml]>:
    - ~yaml load:../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/pvp.yml id:rdm_pvp
  - else:
    - debug log "Unable to load plugins/RandomDeathMessages/language/<yaml[rdm_config].read[language]>/pvp.yml - File is missing!"
    - flag server rdm_missing_file:true

  - if <server.has_file[../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/mythicmobs.yml]>:
    - ~yaml load:../RandomDeathMessages/language/<yaml[rdm_config].read[language]>/mythicmobs.yml id:rdm_mythicmobs
  - else:
    - debug log "Unable to load plugins//RandomDeathMessages/language/<yaml[rdm_config].read[language]>/mobs.yml - File is missing!"
    - flag server rdm_missing_file:true

  - if <server.flag[rdm_missing_file]>:
    - narrate "<red>One or more expected files are missing. RandomDeathMessages will not be enabled."


RandomDeathMessages:
  type: world
  debug: false
  events:
    on server start:
      - inject <script[rdm_init]>

    on reload scripts:
      - inject <script[rdm_init]>

    on player death:

    # If debug messages is on, throw some trash into the log.
    - if <yaml[rdm_config].read[enable_debug_messages]>:
      - debug log "Cause: <context.cause>"
      - debug log "Entity: <context.damager.entity_type>"
      - if <server.list_plugins.contains_text[Depenizen]> && <context.damager.is_mythicmob||false>:
        - debug log "Is Mythic Mob: context.damager.is_mythicmob"
        - debug log "MythicMob Internal Name: <context.damager.mythicmob.internal_name>"

    - if <server.flag[rdm_missing_file]> == true:
      - determine <context.message>

    # Begin PVP
    - if <context.damager.entity_type.contains_any_text[WOLF|PLAYER]||false>:
      - if <context.damager.entity_type> == WOLF && <context.damager.is_tamed||false>:
        - determine <yaml[rdm_pvp].read[WOLF].random.replace[!player].with[<player.name>].replace[!killer].with[<context.damager.owner.name>].parsed>

      # Set a useful var, only used in the PVP context.
      - define killer:<context.damager.name>
      - define weapon:<context.damager.item_in_hand.formatted>

      # Did we get hit by an arrow?
      - if <context.cause> == PROJECTILE:
        - determine <yaml[rdm_pvp].read[RANGED].random.replace[!player].with[<player.name>].replace[!killer].with[<[killer]>].parsed>

      # Melee, empty hand
      - if <context.damager.entity_type> == PLAYER:
        - if <[weapon]> == nothing:
          - determine <yaml[rdm_pvp].read[FISTS].random.replace[!player].with[<player.name>].replace[!killer].with[<[killer]>].parsed>

        # Melee, something in-hand.
        - determine <yaml[rdm_pvp].read[WEAPON].random.replace[!player].with[<player.name>].replace[!killer].with[<[killer]>].replace[!weapon].with[<[weapon]>].parsed>
    # If nothing in here fires, it was an untamed wolf that muirdered the player.
    # End PVP

    # Begin MythicMobs
    - if <server.list_plugins.contains_all_text[Depenizen|MythicMobs]>:
      - if <context.damager.is_mythicmob||false>:
        - determine <yaml[rdm_mythicmobs].read[<context.damager.mythicmob.internal_name>].random.replace[!player].with[<player.name>].parsed>
    # End MythicMobs

    # Begin MC Mobs
    - if <context.cause> == ENTITY_ATTACK || <context.damager.entity_type||false> == SKELETON:
      - determine <yaml[rdm_mobs].read[<context.damager.entity_type>].random.replace[!player].with[<player.name>].parsed>
    # End MC Mobs

    # Begin Environment - this needs work..
    - if <context.cause> != ENTITY_ATTACK:
      - determine <yaml[rdm_env].read[<context.cause>].random.replace[!player].with[<player.name>].parsed>
    # End Environment
