Scriptname StartpackPlayerKitSelector extends Quest

Import UIExtensions
Import JContainers
Import Utility
Import Game
Import PO3_SKSEFunctions
Import SkyMessage

string modRootPath = "Data/SKSE/Plugins/Startpack - Pick your starter kit"

Event OnInit()
    while Utility.IsInMenuMode() || !Game.IsMovementControlsEnabled() || !Game.GetPlayer().Is3DLoaded() || !Game.IsFightingControlsEnabled() || !IsActivateControlsEnabled()
        Utility.WaitMenuMode(1)
    endwhile

    createEmptyPreviewObj()
    createEmptyChoicesObj()
    showLevelList()
    showKitList()
EndEvent

function createEmptyChoicesObj()
    int obj = JMap.object()
    writeObjChoices(obj)
endfunction

string function getChoicesPath()
    return JContainers.userDirectory() + "/Startpack/choices.json"
endfunction

string function getPreviewPath()
    return JContainers.userDirectory() + "/Startpack/preview.json"
endfunction

int function getObjChoices()
    int obj = JValue.readFromFile(getChoicesPath()) as int
    if obj == 0
        obj = JMap.object()
    endif
    return obj
endfunction

function writeObjChoices(int obj)
    return JValue.writeToFile(obj, getChoicesPath())
endfunction

function writePreviewFile(int previewObj)
    JValue.writeToFile(previewObj, getPreviewPath())
endfunction

function createEmptyPreviewObj()
    int previewObj = JMap.object()
    int itemsObj = JMap.object()
    int spellsObj = JMap.object()
    int shoutsObj = JMap.object()
    int skillsObj = JMap.object()
    JMap.setObj(previewObj, "items", itemsObj)
    JMap.setObj(previewObj, "spells", spellsObj)
    JMap.setObj(previewObj, "shouts", shoutsObj)
    JMap.setObj(previewObj, "skills", skillsObj)

    writePreviewFile(previewObj)
endfunction

int function getPreviewObj()
    int previewObj = JValue.readFromFile(getPreviewPath()) as int
    if previewObj == 0
        string errorMessage = "[Startpack] Error reading file: " + getPreviewPath()
        Debug.MessageBox(errorMessage)
        Debug.Trace(errorMessage)
    endif
    return previewObj
endfunction

int function getPreviewGroupObj(string typeName)
    int previewObj = getPreviewObj()
    return JValue.solveObj(previewObj, "." + typeName) as int
endfunction

function setPreviewGroupObj(int obj, string typeName)
    int previewObj = getPreviewObj()
    JMap.setObj(previewObj, typeName, obj)
    writePreviewFile(previewObj)
endfunction

int function loadLangData()
    int langData = JValue.readFromFile(modRootPath + "/langData.json") as int
    if langData == 0
        Debug.MessageBox("Error reading file: langData.json")
        Debug.Trace("[Startpack] Reading language file: " + modRootPath + "/langData.json")
        return 0
    endif
    return langData
endfunction

string function t(string langKey)
    int langData = loadLangData()
    if langData == 0
        return langKey
    endif
    return JValue.solveStr(langData, "." + langKey)
endFunction

function showLevelList()
    int jsonLevelData = JValue.readFromFile(modRootPath + "/levels.json")
    if jsonLevelData == 0
        Debug.MessageBox(t("error.loading_file") + " levels.json")
        return
    endif

    bool enabled = JValue.solveInt(jsonLevelData, ".enabled") as bool
    if !enabled
        return
    endif

    int levelJson = JValue.solveObj(jsonLevelData, ".levels")
    int levelCount = JArray.count(levelJson)

    if levelCount == 0
        Debug.MessageBox(t("error.no_level"))
        return
    endif

    if levelCount > 128
        Debug.MessageBox(t("error.too_many_options"))
        return
    endif
    
    UIListMenu menuLevelList = UIExtensions.getMenu("UIListMenu", true) as UIListMenu
    menuLevelList.AddEntryItem(t("settings.separator"))
    menuLevelList.AddEntryItem(t("level_list_menu.title"))
    menuLevelList.AddEntryItem(t("settings.separator"))
    int listOffset = 3

    int i = 0
    while i < levelCount
        int level = JArray.getObj(levelJson, i)
        string levelName = JValue.solveStr(level, ".name")
        menuLevelList.AddEntryItem(levelName)
        i += 1
    endwhile

    menuLevelList.openMenu()
    int result = menuLevelList.GetResultInt()

    if result <= (listOffset - 1)
        showLevelList()
        return
    endif
    
    result = result - listOffset
    int selectedLevel = JArray.getObj(levelJson, result)
    string levelName = JValue.solveStr(selectedLevel, ".name") as string
    int levelMultiplayer = JValue.solveInt(selectedLevel, ".multiplier") as int
    int objChoices = getObjChoices()
    JMap.setInt(objChoices, "levelEnabled", 1)
    JMap.setStr(objChoices, "levelName", levelName)
    JMap.setInt(objChoices, "levelMultiplier", levelMultiplayer)
    writeObjChoices(objChoices)
EndFunction

int function getOptionsData()
    int jsonOptionsData = JValue.readFromFile(modRootPath + "/options.json")
    if jsonOptionsData == 0
        Debug.MessageBox(t("error.loading_file") + " options.json")
    endif
    return jsonOptionsData
endfunction

function showKitList()
    int objChoices = getObjChoices()
    bool levelEnabled = JValue.solveInt(objChoices, ".levelEnabled") as bool
    string levelName = JValue.solveStr(objChoices, ".levelName")
    int jsonOptionsData = getOptionsData()

    int optionsCount = JArray.count(jsonOptionsData)

    if optionsCount == 0
        Debug.MessageBox(t("error.no_options"))
        return
    endif

    if optionsCount > 128
        Debug.MessageBox(t("error.too_many_options"))
        return
    endif
    
    int optionChooseAnotherLevel = 4
    int listOffset = 5

    UIListMenu menuOptions = UIExtensions.getMenu("UIListMenu", true) as UIListMenu
    menuOptions.AddEntryItem(t("settings.separator"))
    menuOptions.AddEntryItem(t("kit_list_menu.title"))
    menuOptions.AddEntryItem(t("kit_list_menu.level") + " " + levelName)
    if levelEnabled
        menuOptions.AddEntryItem(t("settings.separator"))
        menuOptions.AddEntryItem(t("kit_list_menu.chose_another_level"))
        listOffset += 2
    endif
    menuOptions.AddEntryItem(t("settings.separator"))
    menuOptions.AddEntryItem(t("kit_list_menu.cancel"))

    int optionOptOut = listOffset - 1

    int i = 0
    while i < optionsCount
        int option = JArray.getObj(jsonOptionsData, i)
        string optionName = JValue.solveStr(option, ".name")
        menuOptions.AddEntryItem(optionName)
        i += 1
    endwhile

    menuOptions.openMenu()
    int result = menuOptions.GetResultInt()
    jsonOptionsData = getOptionsData()
    
    if levelEnabled && result == optionChooseAnotherLevel
        showLevelList()
        showKitList()
        return
    elseif result == optionOptOut
        string playerCancel = SkyMessage.Show(t("kit_list_menu.confirm_cancel"), t("kit_list_menu.confirm_yes"), t("kit_list_menu.confirm_no"))

        if playerCancel == t("kit_list_menu.confirm_yes")
            Debug.Notification(t("kit_list_menu.confirm_opt_out"))
        else
            showKitList()
        endif
        return
    elseif result <= optionOptOut
        showKitList()
        return
    endif
    
    result = result - listOffset
    int selectedOption = JArray.getObj(jsonOptionsData, result)
    
    objChoices = getObjChoices()
    JMap.setObj(objChoices, "selectedOption", selectedOption)
    writeObjChoices(objChoices)

    searchKitsForSelectedOption(true)
EndFunction

function searchKitsForSelectedOption(bool preview)
    createEmptyPreviewObj()
    int objChoices = getObjChoices()
    int selectedOption = JValue.solveObj(objChoices, ".selectedOption")
    int kits = JValue.solveObj(selectedOption, ".kits")
    int kitsCount = JArray.count(kits)

    if (kitsCount == 0)
        Debug.MessageBox(t("error.no_kits"))
        return
    endif

    int i = 0
    while i < kitsCount
        string kit = JArray.getStr(kits, i)
        searchItemsFromKit(kit, preview)
        i += 1
    endwhile

    if preview
        previewKit()
    endif
EndFunction

function searchItemsFromKit(string kit, bool preview)
    int objChoices = getObjChoices()
    int levelMultiplier = JValue.solveInt(objChoices, ".levelMultiplier")

    int itemGroup = getPreviewGroupObj("items")
    int spellGroup = getPreviewGroupObj("spells")
    int shoutGroup = getPreviewGroupObj("shouts")
    int skillGroup = getPreviewGroupObj("skills")

    int items = JValue.readFromFile(modRootPath + "/Kits/" + kit + ".json")
    if items == 0
        Debug.MessageBox(t("error.loading_file") + " Kits/" + kit + ".json")
        return
    endif

    int itemsCount = JArray.count(items)

    int i = 0
    while i < itemsCount
        int item = JArray.getObj(items, i)
        string id = JValue.solveStr(item, ".id")
        string plugin = JValue.solveStr(item, ".plugin")
        string itemType = JValue.solveStr(item, ".type")
        bool equip = JValue.solveInt(item, ".equip") as bool
        int amount = JValue.solveInt(item, ".amount")
        int words = JValue.solveObj(item, ".words")
        string name = JValue.solveStr(item, ".name")

        if itemType == "item"
            if preview
                JMap.setInt(itemGroup, name, JValue.solveInt(itemGroup, "." + name) + amount)
                setPreviewGroupObj(itemGroup, "items")
            else
                addItemToPlayer(id, plugin, amount, name, equip)
            endif
        elseif itemType == "spell"
            if preview
                JMap.setInt(spellGroup, name, JValue.solveInt(spellGroup, "." + name) + amount)
                setPreviewGroupObj(spellGroup, "spells")
            else
                addSpellToPlayer(id, plugin, name)
            endif
        elseif itemType == "shout"
            if preview
                JMap.setInt(shoutGroup, name, 0)
                setPreviewGroupObj(shoutGroup, "shouts")
            else
                addShoutToPlayer(id, plugin, name, words)
            endif
        elseif itemType == "skill"
            if levelMultiplier > 0
                int skillLevel = levelMultiplier * amount
                    
                if preview
                    JMap.setInt(skillGroup, name, JValue.solveInt(skillGroup, "." + name) + (levelMultiplier * amount))
                    setPreviewGroupObj(skillGroup, "skills")
                    ;skillsPreview += name + "\n"
                else
                    addSkillToPlayer(id, skillLevel)
                endif
            endif
        else
            Debug.Notification(t("error.unknown_type") + " " + name + " (" + id + "@" + plugin + ")")
        endif
        i += 1
    endwhile
EndFunction

function openPreviewMessageBox(string header, int obj)
    int i = 0
    string previewText = header + "\n\n"
    while i < JValue.count(obj)
        string name = JMap.getNthKey(obj, i)
        int qty = JValue.solveInt(obj, "." + name)
        if qty > 0
            previewText += qty + "x "
        endif
        previewText += name + "\n"
        i += 1
    endwhile
    SkyMessage.Show(previewText, t("preview.confirm"))
endfunction

function previewKit()
    loadLangData()
    int itemGroup = getPreviewGroupObj("items")
    if JValue.count(itemGroup) > 0
        openPreviewMessageBox(t("preview.header_items"), itemGroup)
    endif

    loadLangData()
    int spellGroup = getPreviewGroupObj("spells")
    if JValue.count(spellGroup) > 0
        openPreviewMessageBox(t("preview.header_spells"), spellGroup)
    endif

    loadLangData()
    int shoutGroup = getPreviewGroupObj("shouts")
    if JValue.count(shoutGroup) > 0
        openPreviewMessageBox(t("preview.header_shouts"), shoutGroup)
    endif

    loadLangData()
    int skillGroup = getPreviewGroupObj("skills")
    if JValue.count(skillGroup) > 0
        openPreviewMessageBox(t("preview.header_skills"), skillGroup)
    endif

    loadLangData()
    string button = SkyMessage.Show(t("preview.confirm_message"), t("preview.confirm"), t("preview.cancel"))
    if (button == t("preview.confirm"))
        searchKitsForSelectedOption(false)
    else
        showKitList()
    endif
EndFunction

function addItemToPlayer(string formId, string plugin, int amount, string name, bool equip)
    Form formItem = Game.GetFormFromFile(StringToInt(formId), plugin)
    if formItem != none
        Game.GetPlayer().AddItem(formItem, amount)
        if equip
            Game.GetPlayer().EquipItem(formItem)
        endif
    else
        Debug.Notification(t("error.item_not_found") + " " + name + " (" + formId + "@" + plugin + ")")
    endif
EndFunction

function addSpellToPlayer(string formId, string plugin, string name)
    Spell formSpell = Game.GetFormFromFile(StringToInt(formId), plugin) as Spell
    if formSpell != none
        Game.GetPlayer().AddSpell(formSpell)
    else
        Debug.Notification(t("error.spell_not_found") + " " + name + " (" + formId + "@" + plugin + ")")
    endif
EndFunction

function addShoutToPlayer(string formId, string plugin, string name, int words)
    Shout formShout = Game.GetFormFromFile(StringToInt(formId), plugin) as Shout
    if formShout != none
        int wordsCount = JArray.count(words)
        int i = 0
        while i < wordsCount
            int wordFormId = StringToInt(JArray.getStr(words, i))
            WordOfPower formWord = Game.GetFormFromFile(wordFormId, plugin) as WordOfPower
            if formWord != none
                Game.TeachWord(formWord)
                Game.UnlockWord(formWord)
            else
                Debug.Notification("Word not found: " + JArray.getStr(words, i) + "@" + plugin)
            endif
            i += 1
        endwhile
        Game.GetPlayer().AddShout(formShout)
        Debug.Notification(t("success.added_shout") + " " + name)
    else
        Debug.Notification(t("error.shout_not_found") + " " + name + " (" + formId + "@" + plugin + ")")
    endif
EndFunction

function addSkillToPlayer(string name, int skillLevel)
    Game.IncrementSkillBy(name, skillLevel)
        Debug.Notification(t("success.added_skill_points") + " " + skillLevel + "x " + name)
endFunction
