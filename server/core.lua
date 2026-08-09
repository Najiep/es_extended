Core = {}
Core.JobsPlayerCount = {}
Core.GangsPlayerCount = {}
Core.UsableItemsCallbacks = {}
Core.RegisteredCommands = {}
Core.Pickups = {}
Core.PickupId = 0
Core.PlayerFunctionOverrides = {}
Core.DatabaseConnected = false
Core.playersByIdentifier = {}
Core.JobsLoaded = false
Core.GangsLoaded = false

---@type table<string, CVehicleData>
Core.vehicles = {}
Core.vehicleTypesByModel = {}