Scriptname StartpackMenuActivator extends ObjectReference  

import StartpackPlayerKitSelector

Event OnActivate(ObjectReference akActionRef)
    if akActionRef == Game.GetPlayer()
	 StartpackPlayerKitSelector StartpackQuest = Game.GetFormFromFile(0x804, "Startpack - Pick your pack.esp") as StartpackPlayerKitSelector
        if StartpackQuest != none
            StartpackQuest.startChoices()
        endif
    endif
EndEvent