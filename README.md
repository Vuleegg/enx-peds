

# enx-peds
![example](https://github.com/user-attachments/assets/aac07fa2-8cb8-4cdc-81ed-8863b2cdde10)

**Unique Talk to NPC resource with various types of functions**

## Installation
1. Download the resource and place it in your `resources` folder.
2. Add `ensure enx-peds` to your `server.cfg`.
3. Configure the settings in the `Shared.Podesavanja` file according to your needs.

## Features
- Create interactive NPCs with various options.
- Context-based interactions.
- Conditional availability based on player job roles.

## Usage
To create an interactive NPC, use the following export:

```lua
exports.quantum_peds:Create(56799598, { -- # example index 56799598 ( must to be a number index )
        coords = vector3(coords.x, coords.y, coords.z),
        heading = coords.w,
        distance = 5,
        model = "a_m_m_farmer_01",
        name = "First Name & Last Name",
        label = "Talk to NPC",
        description = "Good morning, can i help you?",
        options = {
            {
                text = "Open Example Function",
                onClick = function() -- # function value you can use instead of that event or serverEvent value 
                    exampleFunction()
                end,
                close = true,
                canInteract = function() -- # Example of can interact function ( if is false option it will not be showed in menu )
                    if QBCore.Functions.GetPlayerData().job.name == "mechanic" then
                        return true
                    else
                        return false
                    end
                end,
            },
            {
                text = "Park my vehicle",
                event = "example:client:Event",
                close = true,
            },
            {
                text = "Vehicle Keys",
                serverEvent = "example:server:Event",
                close = true,
            },
        },
    })
```

## Configuration
Modify the `DATA` file to set up NPCs, vehicle models, and job-based restrictions.

## License
This project is licensed under the **MIT License**. Feel free to modify and distribute it as needed.

## Support
For any issues or questions, feel free to reach out via Discord or open an issue on GitHub.

