window.addEventListener('message', function (event) {
    const data = event.data;
    console.log("NUI veri geldi:", JSON.stringify(data, null, 2));

    if (data.action === "open") {
        document.getElementById("rental-ui").style.display = "flex";

        const carList = document.getElementById("vehicle-list");
        const motorList = document.getElementById("motorcycle-list");

        carList.innerHTML = "";
        motorList.innerHTML = "";

        if (Array.isArray(data.cars)) {
            data.cars.forEach(vehicle => {
                const card = createVehicleCard(vehicle);
                carList.appendChild(card);
            });
        }

        if (Array.isArray(data.motorcycles)) {
            data.motorcycles.forEach(vehicle => {
                const card = createVehicleCard(vehicle);
                motorList.appendChild(card);
            });
        }
    }
});

function createVehicleCard(vehicle) {
    const card = document.createElement("div");
    card.classList.add("vehicle-card");

    const imgPath = `images/${vehicle.model}.png`;

    card.innerHTML = `
        <img src="${imgPath}" onerror="this.onerror=null;this.src='images/placeholder.png';" alt="${vehicle.label}">
        <div style="flex-grow:1;">
            <h3>${vehicle.label}</h3>
            <p>Fiyat: $${vehicle.price}</p>
        </div>
        <button onclick="rent('${vehicle.model}', ${vehicle.price})">Kirala</button>
    `;

    return card;
}

function closeMenu() {
    document.getElementById("rental-ui").style.display = "none";
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST'
    });
}

function rent(model, price) {
    fetch(`https://${GetParentResourceName()}/rentVehicle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ model, price })
    }).then(() => {
        closeMenu();
    });
}
