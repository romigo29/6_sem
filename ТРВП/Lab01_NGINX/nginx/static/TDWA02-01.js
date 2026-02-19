const resultEl = document.getElementById("result");

async function handleFetch(method, data = null) {
    let url = "/api/Save-JSON";

    let options = { method };

    if (data) {
        options.headers = { "Content-Type": "application/json" };
        options.body = JSON.stringify(data);
    }

    try {
        const response = await fetch(url, options);


        const text = await response.text();
        let json;
        try {
            json = text ? JSON.parse(text) : {};
        } catch {
            json = { error: text };
        }

        resultEl.textContent = JSON.stringify(json, null, 2);
    } catch (err) {
        resultEl.textContent = "Ошибка: " + err;
    }
}


document.getElementById("btnGet").addEventListener("click", () => handleFetch("GET"));

document.getElementById("btnPost").addEventListener("click", () => {
    const data = {
        op: document.getElementById("op").value,
        x: Number(document.getElementById("x").value),
        y: Number(document.getElementById("y").value)
    };
    handleFetch("POST", data);
});

document.getElementById("btnPut").addEventListener("click", () => {
    const data = {
        op: document.getElementById("op").value,
        x: Number(document.getElementById("x").value),
        y: Number(document.getElementById("y").value)
    };
    handleFetch("PUT", data);
});

document.getElementById("btnDelete").addEventListener("click", () => handleFetch("DELETE"));
