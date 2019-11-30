TrashMath:
  type: command
  debug: false
  name: trashmath
  usage: /trashmath
  script:
    - define num:1000
    - narrate "10% of <[num]> = <[num].as_element.mul[-1]>"
