#
#
# Random Death Messages
#
# Provides random essages when players expire in.. unfortunate manners.
#
# author GoMinecraft
# script-version 0.1
#
# Recommendation:
# * Install Depenizen, required if you want custom death messages for MythicMobs
#

rdm_init:
  type: task
  debug: false
  script:
  - if <server.has_file[../RandomDeathMessages/mobs.yml]> && <server.has_file[../RandomDeathMessages/environment.yml]> && <server.has_file[../RandomDeathMessages/pvp.yml]> && <server.has_file[../RandomDeathMessages/mythicmobs.yml]>:
    - ~yaml load:../RandomDeathMessages/mobs.yml id:rdm_mobs
    - ~yaml load:../RandomDeathMessages/environment.yml id:rdm_env
    - ~yaml load:../RandomDeathMessages/pvp.yml id:rdm_pvp
    - ~yaml load:../RandomDeathMessages/mythicmobs.yml id:rdm_mythic
    - define enabled:potato
  - else:
    - narrate "One or more expected files are missing. RandomDeathMessages will not be enabled."
    - define enabled:0


RandomDeathMessages:
  type: world
  debug: false
  events:
    on player death:
    - if <[enabled]> == 0:
      - determine <context.message>

    # If Enabled is anything other than 0.. lets do this!

    # Set a useful shortcut var, used globally
    - define player:<player.name>

    # PVP Logic
    - if <context.damager.entity_type> == PLAYER:

      # Set a useful var, only used in the PVP context.
      - define killer:<context.damager.name>
      - define weapon:<context.damager.item_in_hand.formatted>
      # Did we get hit by an arrow?
      - if <context.cause> == PROJECTILE:
        - determine <yaml[rdm_pvp].list_keys[projectile].random.replace[!player].with[<[player]>].replace[!killer].with[<[killer]>].parsed>

      # Melee, empty hand
      - if <[weapon]> == "nothing":
        - determine <yaml[rdm_pvp].list_keys[fists].random.replace[!player].with[<[player]>].replace[!killer].with[<[killer]>]>
      # Melee, something in-hand.
      - determine <yaml[rdm_pvp].list_keys[weapon].random.replace[!player].with[<[player]>].replace[!killer].with[<[killer]>].replace[!weapon].with[<[weapon]>].parsed>
    # End PVP

    # MythicMobs, check this first
    - if <context.damager.is_mythicmob>:
      - determine <yaml[rdm_mythic].list_keys[<context.damager.mythicmob.internal_name>].random.replace[!player].with[<[player]>].parsed>
    # End MythicMobs

    # MC Mobs
    - if <context.cause> == ENTITY_ATTACK || <context.damager.entity_type> == SKELETON:
      - determine <yaml[rdm_mobs].list_keys[<context.damager.entity_type>].random.replace[!player].with[<[player]>].parsed>
    # End MC Mobs

    # Environment deaths
    - else
      - determine <yaml[rdm_env].list_keys[<context.cause>].random.replace[!player].with[<[player]>].parsed>
