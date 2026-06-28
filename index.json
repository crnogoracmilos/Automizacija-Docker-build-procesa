const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;

// --- MIDDLEWARE OKRUŽENJE ---
app.use(cors());                  // Omogućava pristup API-ju sa drugih domena (npr. frontend ili WebView mobilna aplikacija)
app.use(express.json());          // Omogućava serveru da čita JSON podatke iz tela (body) zahteva
app.use(morgan('dev'));           // Loguje svaki HTTP zahtev u konzoli (metoda, statusni kod, vreme izvršenja)

// --- SIMULIRANA BAZA PODATAKA (In-Memory Data) ---
let zaposleni = [
    { id: 1, ime: "Petar Petrović", pozicija: "Menadžer", status: "Aktivan" },
    { id: 2, ime: "Ana Ivanović", pozicija: "Recepcija", status: "Aktivan" },
    { id: 3, ime: "Marko Marković", pozicija: "Obezbeđenje", status: "Na pauzi" }
];

let smene = [
    { id: 101, zaposleniId: 2, datum: "2026-07-01", tipSmene: "Prva (07:00 - 15:00)" },
    { id: 102, zaposleniId: 1, datum: "2026-07-01", tipSmene: "Druga (15:00 - 23:00)" }
];

// --- REST API RUTE ---

// 1. Osnovna ruta (Health Check)
app.get('/', (req, res) => {
    res.json({
        status: "U radu",
        poruka: "Sistem za upravljanje smenama je bezbedno podignut kroz CI/CD pipeline.",
        verzija: "1.0.0"
    });
});

// 2. Preuzimanje svih zaposlenih
app.get('/api/zaposleni', (req, res) => {
    res.json(zaposleni);
});

// 3. Preuzimanje kompletnog rasporeda smena
app.get('/api/smene', (req, res) => {
    // Spajamo podatke o smenama sa podacima o zaposlenima radi kompletnog prikaza
    const detaljanRaspored = smene.map(smena => {
        const radnik = zaposleni.find(z => z.id === smena.zaposleniId);
        return {
            id: smena.id,
            datum: smena.datum,
            tipSmene: smena.tipSmene,
            radnik: radnik ? radnik.ime : "Nepoznat radnik"
        };
    });
    res.json(detaljanRaspored);
});

// 4. Kreiranje/Zakazivanje nove smene (Sa validacijom)
app.post('/api/smene', (req, res) => {
    const { zaposleniId, datum, tipSmene } = req.body;

    // Validacija: Da li su poslati svi obavezni podaci?
    if (!zaposleniId || !datum || !tipSmene) {
        return res.status(400).json({ greska: "Nedostaju obavezni podaci: zaposleniId, datum ili tipSmene." });
    }

    // Validacija: Da li radnik uopšte postoji u sistemu?
    const radnikPostoji = zaposleni.some(z => z.id === parseInt(zaposleniId));
    if (!radnikPostoji) {
        return res.status(404).json({ greska: `Zaposleni sa ID-jem ${zaposleniId} ne postoji u sistemu.` });
    }

    // Kreiranje nove smene
    const novaSmena = {
        id: smene.length > 0 ? Math.max(...smene.map(s => s.id)) + 1 : 101,
        zaposleniId: parseInt(zaposleniId),
        datum,
        tipSmene
    };

    smene.push(novaSmena);
    res.status(201).json({ poruka: "Smena uspešno zakazana!", smena: novaSmena });
});

// 5. Brisanje/Otkazivanje smene
app.delete('/api/smene/:id', (req, res) => {
    const smenaId = parseInt(req.params.id);
    const indeks = smene.findIndex(s => s.id === smenaId);

    if (indeks === -1) {
        return res.status(404).json({ greska: "Smena sa zadatim ID-jem nije pronađena." });
    }

    smene.splice(indeks, 1);
    res.json({ poruka: `Smena sa ID-jem ${smenaId} je uspešno otkazana.` });
});

// --- GLOBALNI ERROR HANDLER (Middleware za upravljanje greškama) ---
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ greska: "Došlo je do interne greške na serveru!" });
});

// --- POKRETANJE SERVERA ---
app.listen(PORT, () => {
    console.log(`[SERVER] REST API uspesno pokrenut na portu ${PORT}`);
});
