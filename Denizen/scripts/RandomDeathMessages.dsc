#
#
# Random Death Messages
#
# Provides random essages when players expire in.. unfortunate manners.
#
# author  : GoMinecraft ( Discord: GoMinecraft#1421 )
# version : 0.1
#
# Recommendation(s):
# * Install Depenizen, required if you want custom death messages for MythicMobs.
# * Set enable_mythicmobs to true if you have Depenizen.
#

rdm_config:
  type: yaml data
  # Begin config
  enable_pvp: true
  enable_mobs: true
  enable_environment: true
  enable_mythicmobs: true
  # End config

# ---- Don't edit below here unless you know what you're doing.
# ---- I definitely don't know what I'm doing.

rdm_init:
  type: task
  debug: true
  script:
  - define missing_file:false
  # Load our files..
  - if <server.has_file[../RandomDeathMessages/mobs.yml]>:
    - ~yaml load:../RandomDeathMessages/mobs.yml id:rdm_mobs
  - else:
    - debug log "Unable to load plugins/RandomDeathMessages/mobs.yml - File is missing!"
    - define missing_file:true

  - if <server.has_file[../RandomDeathMessages/environment.yml]>:
    - ~yaml load:../RandomDeathMessages/environment.yml id:rdm_env
  - else:
    - debug log "Unable to load plugins/RandomDeathMessages/environment.yml - File is missing!"
    - define missing_file:true

  - if <server.has_file[../RandomDeathMessages/pvp.yml]>:
    - ~yaml load:../RandomDeathMessages/pvp.yml id:rdm_pvp
  - else:
    - debug log "Unable to load plugins/RandomDeathMessages/pvp.yml - File is missing!"
    - define missing_file:true

  - if <server.has_file[../RandomDeathMessages/mythicmobs.yml]>:
    - ~yaml load:../RandomDeathMessages/mythicmobs.yml id:rdm_mythic
  - else:
    - debug log "Unable to load plugins//RandomDeathMessages/mobs.yml - File is missing!"
    - define missing_file:true

  - if <[missing_file]> == true:
    - narrate "<red>One or more expected files are missing. RandomDeathMessages will not be enabled."


RandomDeathMessages:
  type: world
  debug: true
  events:
    on player death:
    

    - if <[missing_file]> == 0:
      - determine <context.message>

    # If Enabled is anything other than 0.. lets do this!

    # Set a useful shortcut var, used globally
    - define player:<player.name>

    # Begin PVP
    - if <script[rdm_config].yaml_key[enable_pvp]> == true && <context.damager.entity_type> == PLAYER:

      # Set a useful var, only used in the PVP context.
      - define killer:<context.damager.name>
      - define weapon:<context.damager.item_in_hand.formatted>
      # Did we get hit by an arrow?
      - if <context.cause> == PROJECTILE:
        - determine <yaml[rdm_pvp].list_keys[RANGED].random.replace[!player].with[<[player]>].replace[!killer].with[<[killer]>].parsed>
    

      # Melee, empty hand
      - if <[weapon]> == "nothing":
        - determine <yaml[rdm_pvp].list_keys[FISTS].random.replace[!player].with[<[player]>].replace[!killer].with[<[killer]>]>
      # Melee, something in-hand.
      - determine <yaml[rdm_pvp].list_keys[WEAPON].random.replace[!player].with[<[player]>].replace[!killer].with[<[killer]>].replace[!weapon].with[<[weapon]>].parsed>
    # End PVP

    # Begin MythicMobs
    - if <script[rdm_config].yaml_key[enable_mythicmobs]> && <context.damager.is_mythicmob>:
      - determine <yaml[rdm_mythic].list_keys[<context.damager.mythicmob.internal_name>].random.replace[!player].with[<[player]>].parsed>
    
    # End MythicMobs

    # Begin MC Mobs
    - if <script[rdm_config].yaml_key[enable_mobs]> && <[enable_mobs]> && <context.cause> == ENTITY_ATTACK || <context.damager.entity_type> == SKELETON:
      - determine <yaml[rdm_mobs].list_keys[<context.damager.entity_type>].random.replace[!player].with[<[player]>].parsed>
    # End MC Mobs

    # Begin Environment - this needs work..
    - if <script[rdm_config].yaml_key[enable_environment]> && <context.cause> != ENTITY_ATTACK:
      - determine <yaml[rdm_env].list_keys[<context.cause>].random.replace[!player].with[<[player]>].parsed>
    # End Environment
