local NOTIFY_TYPES = {
    INFO = "^5[%s]^7-^6[INFO]^7 %s",
    SUCCESS = "^5[%s]^7-^2[SUCCESS]^7 %s",
    ERROR = "^5[%s]^7-^1[ERROR]^7 %s",
}

local function notify(notifyType, resourceName, message, ...)
    local formattedMessage = string.format(message, ...)
    local template = NOTIFY_TYPES[notifyType] or NOTIFY_TYPES.INFO
    print(template:format(resourceName or GetCurrentResourceName(), formattedMessage))
end

local function validateGrades(grades)
    local seen = {}

    for _, grade in pairs(grades) do
        local gradeNumber = tonumber(grade.grade)
        if gradeNumber == nil or not grade.name or grade.name == "" or not grade.label or grade.label == "" then
            return false
        end

        if seen[gradeNumber] then
            return false
        end

        seen[gradeNumber] = true
    end

    return true
end

local function generateGangTable(name, label, grades)
    local gang = { name = name, label = label, grades = {} }

    for _, grade in pairs(grades) do
        gang.grades[tostring(grade.grade)] = {
            gang_name = name,
            grade = tonumber(grade.grade),
            name = grade.name,
            label = grade.label,
        }
    end

    return gang
end

--- Create a gang at runtime using the same definition/cache pattern as ESX.CreateJob.
---@param name string
---@param label string
---@param grades table
---@return boolean success
function ESX.CreateGang(name, label, grades)
    local currentResourceName = GetInvokingResource() or GetCurrentResourceName()

    if type(name) ~= "string" or name == "" then
        notify("ERROR", currentResourceName, "Missing argument `name`")
        return false
    end

    if type(label) ~= "string" or label == "" then
        notify("ERROR", currentResourceName, "Missing argument `label`")
        return false
    end

    if type(grades) ~= "table" or not next(grades) then
        notify("ERROR", currentResourceName, "Missing argument `grades`")
        return false
    end

    if not validateGrades(grades) then
        notify("ERROR", currentResourceName, "Invalid or duplicate gang grade definition for `%s`", name)
        return false
    end

    while not Core.GangsLoaded do
        Wait(100)
    end

    if ESX.Gangs[name] then
        notify("ERROR", currentResourceName, "Gang already exists: `%s`", name)
        return false
    end

    local queries = {
        { query = "INSERT INTO `gangs` (`name`, `label`) VALUES (?, ?)", values = { name, label } },
    }

    for _, grade in pairs(grades) do
        queries[#queries + 1] = {
            query = "INSERT INTO `gang_grades` (`gang_name`, `grade`, `name`, `label`) VALUES (?, ?, ?, ?)",
            values = { name, tonumber(grade.grade), grade.name, grade.label },
        }
    end

    local success = exports.oxmysql:transaction_async(queries)
    if not success then
        notify("ERROR", currentResourceName, "Failed to create gang `%s`", name)
        return false
    end

    ESX.Gangs[name] = generateGangTable(name, label, grades)
    notify("SUCCESS", currentResourceName, "Gang created successfully: `%s`", name)
    TriggerEvent("esx:gangCreated", name, ESX.Gangs[name])
    return true
end
