class UserModel {

    constructor() {
        this.users = [
            {
                id: 1,
                name: "Igor",
                surname: "Romanov"
            }
        ];

        this.idCounter = this.users.length
            ? Math.max(...this.users.map(u => u.id)) + 1
            : 1;
    }

    getAll() {
        return this.users;
    }

    create(data) {
        const newUser = {
            id: this.idCounter++,
            name: data.name,
            surname: data.surname
        };

        this.users.push(newUser);
        return newUser;
    }

    getById(id) {
        return this.users.find(user => user.id == id);
    }

    update(id, data) {
        const index = this.users.findIndex(user => user.id == id);

        if (index !== -1) {
            this.users[index] = {
                ...this.users[index],
                ...data
            };
            return this.users[index];
        }

        return null;
    }

    delete(id) {
        const index = this.users.findIndex(user => user.id == id);

        if (index !== -1) {
            this.users.splice(index, 1);
            return true;
        }

        return false;
    }
}

module.exports = new UserModel();