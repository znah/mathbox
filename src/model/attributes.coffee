###
 Custom attribute model
 - Stores attributes in three.js uniform-style objects so they can be passed around by reference into renderables
 - Avoids copying value objects on set
 - Coalesces update notifications per object
###

class Attributes
  constructor: (@traits, @types) ->
    @pending = []

  make: (type) ->
    type: type.uniform?()
    value: type.make()

  getSpec: (name) ->
    @traits[name]

  queue: (callback) ->
    @pending.push callback

  apply: (object, traits = []) ->
    new Data object, traits, @

  digest: () ->
    limit = 10

    while @pending.length > 0 && --limit > 0
      [calls, @pending] = [@pending, []]
      callback() for callback in calls

    if limit == 0
      console.error 'While digesting: ', object
      throw Error("Infinite loop in Data::digest")

    return


class Data
  constructor: (object, traits = [], attributes) ->

    # Get/set
    get = (key) =>
      @[key]?.value
    set = (key, value, ignore) =>
      replace = validate key, value, @[key].value
      @[key].value = replace if replace != undefined
      change key if !ignore

    object.get = (key) =>
      if key?
        get(key)
      else
        out = {}
        out[key] = value.value for key, value of @
        out

    object.set = (key, value, ignore) ->
      if key? and value?
        set(key, value, ignore) if validators[key]?
      else
        options = key
        set(key, value, ignore) for key, value of options when validators[key]?
      return

    # Validate
    makers = {}
    validators = {}
    validate = (key, value, target) ->
      validators[key] value, target
    object.validate = (key, value) ->
      make = makers[key]
      target = make() if make?
      replace = validate key, value, target
      if replace != undefined then replace else target

    # Coalesce changes
    dirty = false
    changes = {}
    change = (key) =>
      if !dirty
        dirty = true
        attributes.queue digest

      # Log change
      changes[key] = true

      # Mark trait as dirty
      trait = key.split('.')[0]
      changes[trait] = true

    event =
      type: 'change'
      changed: null

    digest = () ->
      event.changed = changes
      changes = {}
      dirty = false

      object.trigger event

    # Add in traits
    values = {}
    for trait in traits
      [trait, name] = trait.split ':'
      name ?= trait
      spec = attributes.getSpec trait
      for key, options of spec
        key = [name, key].join '.'
        @[key] =
          type: options.uniform?()
          value: options.make()

        makers[key] = options.make
        validators[key] = options.validate

module.exports = Attributes
