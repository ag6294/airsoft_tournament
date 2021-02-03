import 'package:airsoft_tournament/constants/style.dart';
import 'package:flutter/material.dart';

class PrivacyRoute extends StatelessWidget {
  static const routeName = '/privacy';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Title(
            'Informativa Privacy',
          ),
          Subtitle(
            'Informativa ai sensi dell\'art. 13 del Codice della Privacy',
          ),
          Subtitle(
            'Ai sensi dell\'articolo 13 del codice della D.Lgs. 196/2003, vi rendiamo le seguenti informazioni.',
          ),
          Paragraph(
            'Noi di http://www.airsoftgamemakers.com/ e ASG - AirsoftGamemakers riteniamo che la privacy dei nostri utenti sia estremamente importante. Questo documento descrive dettagliatamente i tipi di informazioni personali raccolti e registrati dal nostro sito e come essi vengano utilizzati.',
          ),
          Title('File di Registrazione (Log Files)'),
          Paragraph(
              'Come molti altri siti web, il nostro utilizza file di log. Questi file registrano semplicemente i visitatori del sito - di solito una procedura standard delle aziende di hosting e dei servizi di analisi degli hosting. Le informazioni contenute nei file di registro comprendono indirizzi di protocollo Internet (IP), il tipo di browser, Internet Service Provider (ISP), informazioni come data e ora, pagine referral, pagine d\'uscita ed entrata o il numero di clic. Queste informazioni vengono utilizzate per analizzare le tendenze, amministrare il sito, monitorare il movimento degli utenti sul sito e raccogliere informazioni demografiche. Gli indirizzi IP e le altre informazioni non sono collegate a informazioni personali che possono essere identificate, dunque tutti i dati sono raccolti in forma assolutamente anonima.'),
          Title('Finalità del trattamento'),
          Paragraph(
              'I dati possono essere raccolti per una o più delle seguenti finalità: '
              'fornire l\'accesso ad aree riservate del Portale e di Portali/siti collegati con il presente e all\'invio di comunicazioni anche di carattere commerciale, notizie, aggiornamenti sulle iniziative di questo sito e delle società da essa controllate e/o collegate e/o Sponsor. '
              'eventuale cessione a terzi dei suddetti dati, sempre finalizzata alla realizzazione di campagne di email marketing ed all\'invio di comunicazioni di carattere commerciale. '
              'eseguire gli obblighi previsti da leggi o regolamenti; '
              'gestione contatti;'),
          Title('Modalità del trattamento'),
          Paragraph(
              'I dati verranno trattati con le seguenti modalità: raccolta dati con modalità single-opt, in apposito database; registrazione ed elaborazione su supporto cartaceo e/o magnetico; organizzazione degli archivi in forma prevalentemente automatizzata, ai sensi del Disciplinare Tecnico in materia di misure minime di sicurezza, Allegato B del Codice della Privacy.'),
          Title('Natura dei dati raccolti'),
          Paragraph(
              'La piattaforma raccoglie i seguenti dati sensibili: email(obbligatorio), nome, cognome, data e luogo di nascita, codice fiscale'),
          Paragraph(
              'L\'applicazione inoltre richiede accesso alle seguenti componenti software, ed ai dati che ne conseguono: fotocamera, galleria, local storage, localizzazione.'),
          Title('Diritti dell\'interessato'),
          Paragraph(
              'Ai sensi ai sensi dell\'art. 7 (Diritto di accesso ai dati personali ed altri diritti) del Codice della Privacy, vi segnaliamo che i vostri diritti in ordine al trattamento dei dati sono: conoscere, mediante accesso gratuito l\'esistenza di trattamenti di dati che possano riguardarvi; essere informati sulla natura e sulle finalità del trattamento ottenere a cura del titolare, senza ritardo: la conferma dell\'esistenza o meno di dati personali che vi riguardano, anche se non ancora registrati, e la comunicazione in forma intellegibile dei medesimi dati e della loro origine, nonché della logica e delle finalità su cui si basa il trattamento; la richiesta può essere rinnovata, salva l\'esistenza di giustificati motivi, con intervallo non minore di novanta giorni; la cancellazione, la trasformazione in forma anonima o il blocco dei dati trattati in violazione di legge, compresi quelli di cui non è necessaria la conservazione in relazione agli scopi per i quali i dati sono stati raccolti o successivamente trattati; l\'aggiornamento, la rettifica ovvero, qualora vi abbia interesse, l\'integrazione dei dati esistenti; opporvi in tutto o in parte per motivi legittimi al trattamento dei dati personali che vi riguardano ancorché pertinenti allo scopo della raccolta;'),
          Paragraph(
              'Vi segnaliamo che il titolare del trattamento ad ogni effetto di legge è: Alessandro Giordano, Codice Fiscale: GRDLSN94B06219 residente a Torino (TO), E-mail: support@airsoftgamemakers.com.'),
          Paragraph(
              'Per esercitare i diritti previsti all\'art. 7 del Codice della Privacy ovvero per la cancellazione dei vostri dati dall\'archivio, è sufficiente contattarci attraverso uno dei canali messi a disposizione.Tutti i dati sono protetti attraverso l\'uso di antivirus, firewall e protezione attraverso password.'),
          Title('Consenso'),
          Paragraph(
              'Usando il nostro sito web, acconsenti alla nostra politica sulla privacy e accetti i suoi termini. Se desideri ulteriori informazioni o hai domande sulla nostra politica sulla privacy non esitare a contattarci.'),
        ],
      ),
    );
  }
}

class Title extends StatelessWidget {
  final String text;

  const Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Text(
        text,
        style: kTitle,
      ),
    );
  }
}

class Subtitle extends StatelessWidget {
  final String text;

  const Subtitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Text(
        text,
        style: kMediumText,
      ),
    );
  }
}

class Paragraph extends StatelessWidget {
  final String text;

  const Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Text(
        text,
        style: kSmallText,
      ),
    );
  }
}
