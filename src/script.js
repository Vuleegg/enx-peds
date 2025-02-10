window.addEventListener("message", function (event) {
    const data = event.data;

    switch (data.action) {
        case "textUIshow":
            const debugUi = document.getElementById("debug-ui");
            debugUi.classList.remove("hidden");
            document.getElementById("slovo").textContent = data.slovo ?? "E"; 
            document.getElementById("porukica").textContent = data.text;
            break;
        
        case "textUIhide":
            const debugUiHide = document.getElementById("debug-ui");
            debugUiHide.classList.add("hidden");
            break;

        case "pedUIshow":
            const pedUi = document.getElementById("ped-ui");
            pedUi.classList.remove("hidden");

            const header = pedUi.querySelector(".text-xl.font-semibold");
            header.textContent = data.name || "Unknown NPC";

            const description = pedUi.querySelector(".bg-gray-800.text-black.p-2.rounded-md.my-2 p");
            description.textContent = data.description || "Interact with this NPC.";

            const buttonContainer = pedUi.querySelector(".grid.grid-cols-2.gap-2");
            buttonContainer.innerHTML = "";

            data.options.forEach((option, index) => {
                if (option.canInteract && typeof option.canInteract === "function" && !option.canInteract(data.entity)) {
                    return;
                }

                const button = document.createElement("button");
                button.className = "bg-gray-800 p-2 rounded-md flex items-center space-x-2 hover:bg-gray-700 hover:scale-105 transition-transform";
                button.innerHTML = `   
                    <div class="bg-gray-600 bg-opacity-50 border text-white h-6 w-6 flex items-center justify-center rounded-md">
                        <span class="font-bold text-sm">${index}</span>
                    </div>
                    <p class="text-white text-sm">${option.text}</p>
                `;

                button.addEventListener("click", () => {
                    if (option.serverEvent) {
                        $.post('https://enx-peds/action', JSON.stringify({
                            actionType: "serverEvent",
                            eventName: option.serverEvent,
                            args: option.args || {}
                        }));
                    } else if (option.event) {
                        $.post('https://enx-peds/action', JSON.stringify({
                            actionType: "event",
                            eventName: option.event,
                            args: option.args || {}
                        }));
                    } else if (option.onClick) {
                        $.post('https://enx-peds/action', JSON.stringify({
                            actionType: "onClick",
                            optionId: option.id
                        }));
                    }

                    if (option.close === true) {
                        pedUi.classList.add("hidden");
                        $.post('https://enx-peds/close', JSON.stringify({}));
                    }
                });

                buttonContainer.appendChild(button);
            });
            break;

        default:
            console.log("Unknown action", data.action);
            break;
    }
});

window.addEventListener("keyup", function(event) {
    if (event.key === "Escape" || event.key === "Backspace") {
        const pedUi = document.getElementById("ped-ui");
        pedUi.classList.add("hidden");
        $.post('https://enx-peds/close', JSON.stringify({}));
    }
});
