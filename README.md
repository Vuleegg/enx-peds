# enx-peds

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
exports.quantum_peds:Create(56799598, {
        coords = vector3(Shared.Podesavanja['vozilo']['coords'].x, Shared.Podesavanja['vozilo']['coords'].y, Shared.Podesavanja['vozilo']['coords'].z),
        heading = Shared.Podesavanja['vozilo']['coords'].w,
        distance = 5,
        model = Shared.Podesavanja['vozilo']['ped_model'],
        name = "Frikni Patofni",
        label = "Pricaj sa radnikom na parkingu",
        description = "Dobar dan, kako vam mogu pomoci?",
        options = {
            {
                text = "Daj da vidim sta cu voziti danas",
                onClick = function()
                    local opcije = {}
                        for k, v in pairs(Shared.Podesavanja['vozilo']['modeli']) do
                            opcije[#opcije + 1] = {
                                title = v.label,
                                icon = 'fa-solid fa-screwdriver-wrench',
                                onSelect = function()
                                    local metadata = Shared.Podesavanja['vozilo']
                                    SpawnujKolca(v.model, vec3(metadata['spawnpoint'].x, metadata['spawnpoint'].y, metadata['spawnpoint'].z), metadata['spawnpoint'].w)
                                end,
                                description = 'Izvadi vozilo',
                                args = { id = v.id, name = v.name, kreirajprop = v.kreirajprop },
                                arrow = true,
                            }
                        end
                        lib.registerContext({
                            id = 'menivozilameh',
                            title = 'Lista Vozila',
                            options = opcije
                        })
                        lib.showContext('menivozilameh')
                end,
                close = true,
                canInteract = function()
                    if QBCore.Functions.GetPlayerData().job.name == "mehanicar" then
                        return true
                    else
                        return false
                    end
                end,
            },
            {
                text = "Parkiraj mi vozilo",
                onClick = function()
                    obrisiNajblize()
                end,
                close = true,
                canInteract = function()
                    if QBCore.Functions.GetPlayerData().job.name == "mehanicar" then
                        return true
                    else
                        return false
                    end
                end,
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

