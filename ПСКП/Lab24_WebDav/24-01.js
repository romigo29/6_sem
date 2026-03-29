import express from 'express';
import multer from 'multer';
import { createClient } from 'webdav';

const app = express();
const upload = multer({ storage: multer.memoryStorage() });

// Подключение к WebDAV
const client = createClient("https://app.koofr.net/dav/Koofr", {
    username: "<login email here>",
    password: "<generated password here>"
});

const PORT = 3000;

// POST /md/:name — создать директорию
app.post('/md/:name', async (req, res) => {
    try {
        if (await client.exists(`/${req.params.name}`)) {
            return res.status(408).send('Директорий уже существует');
        }
        await client.createDirectory(`/${req.params.name}`);
        res.send('Директорий создан');
    } catch (e) {
        res.status(500).send(e.message);
    }
});

// POST /rd/:name — удалить директорию
app.post('/rd/:name', async (req, res) => {
    try {
        if (!(await client.exists(`/${req.params.name}`))) {
            return res.status(408).send('Директория не существует');
        }
        await client.deleteFile(`/${req.params.name}`);
        res.send('Директорий удалён');
    } catch (e) {
        res.status(500).send(e.message);
    }
});

// POST /up/:name — загрузить файл в ФХ
app.post('/up/:name', upload.single('file'), async (req, res) => {
    try {
        await client.putFileContents(`/${req.params.name}`, req.file.buffer);
        res.send('Файл загружен');
    } catch (e) {
        res.status(408).send('Запись не может быть выполнена');
    }
});

// POST /down/:name — скачать файл из ФХ
app.post('/down/:name', async (req, res) => {
    try {
        if (!(await client.exists(`/${req.params.name}`))) {
            return res.status(404).send('Файл не найден');
        }
        const data = await client.getFileContents(`/${req.params.name}`);
        res.set('Content-Disposition', `attachment; filename="${req.params.name}"`);
        res.send(Buffer.from(data));
    } catch (e) {
        res.status(500).send(e.message);
    }
});

// POST /del/:name — удалить файл из ФХ
app.post('/del/:name', async (req, res) => {
    try {
        if (!(await client.exists(`/${req.params.name}`))) {
            return res.status(404).send('Файл не найден');
        }
        await client.deleteFile(`/${req.params.name}`);
        res.send('Файл удалён');
    } catch (e) {
        res.status(500).send(e.message);
    }
});

// POST /copy/:src/:dst — копировать файл
app.post('/copy/:src/:dst', async (req, res) => {
    try {
        if (!(await client.exists(`/${req.params.src}`))) {
            return res.status(404).send('Исходный файл не найден');
        }
        await client.copyFile(`/${req.params.src}`, `/${req.params.dst}`);
        res.send('Файл скопирован');
    } catch (e) {
        res.status(408).send('Файл не может быть записан');
    }
});

// POST /move/:src/:dst — переместить файл
app.post('/move/:src/:dst', async (req, res) => {
    try {
        if (!(await client.exists(`/${req.params.src}`))) {
            return res.status(404).send('Исходный файл не найден');
        }
        await client.moveFile(`/${req.params.src}`, `/${req.params.dst}`);
        res.send('Файл перемещён');
    } catch (e) {
        res.status(408).send('Файл не может быть записан');
    }
});

app.listen(PORT, () => console.log(`Сервер запущен: http://localhost:${PORT}`));