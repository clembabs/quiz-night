/// The landing page's words, kept apart from its layout. Everything here
/// describes the game as it works today; planned features say "coming soon".
abstract final class LandingContent {
  static const eyebrow = 'The live elimination quiz for any crowd';
  static const headline = 'Survive the round. Win the night.';
  static const lead =
      'The host puts the questions on a big screen. Everyone answers on '
      'their own phone. After each round the bottom of the leaderboard is '
      'knocked out, until the finalists face a buzzer round.';

  static const previewCaption =
      'The big screen shows the question and the clock. Every phone shows '
      'four big answer buttons, A to D, each with its own colour and shape.';

  static const steps = [
    Step(
      'Host opens a room',
      'A four-digit room code and a QR code appear '
          'on the big screen.',
    ),
    Step(
      'Players join',
      'They scan the QR, or type the code and a '
          'nickname on their phone.',
    ),
    Step(
      'Answer and survive',
      'Faster right answers score more. After each '
          'round the lowest scores are knocked out.',
    ),
    Step(
      'Buzzer final',
      'The last few players race to buzz first, then tap '
          'the answer on their phone.',
    ),
  ];

  static const forPlayers = [
    Step(
      'Join',
      'Open this site on any phone, enter the room code from the '
          'big screen and pick a nickname. No app download and no account.',
    ),
    Step(
      'Answer',
      'Each question shows four options on your phone, marked '
          'A to D with a shape and a colour. Tap to lock in your answer before '
          'the timer runs out. Right answers score 500 to 1000 points: the '
          'faster, the more.',
    ),
    Step(
      'Survive the cut',
      'After each round the leaderboard shows an '
          'elimination line. Below it, you are out. Your phone tells you if '
          'you are safe or in the danger zone.',
    ),
    Step(
      'Keep playing if you’re out',
      'Knocked-out players carry on '
          'answering for a shadow score, and back a finalist before the '
          'final.',
    ),
    Step(
      'The final',
      'Finalists get a buzzer. Buzz first, then tap your '
          'answer. A wrong answer locks you out of that question. The podium '
          'shows the top three.',
    ),
  ];

  static const forHosts = [
    Step(
      'Create a room',
      'Tap “Host a game” on a laptop. Choose how players '
          'are knocked out, how many questions a round, how many seconds each '
          'and how many reach the final.',
    ),
    Step(
      'Put it on the big screen',
      'The room code and a QR code appear in '
          'large type. The joined count rises as players arrive.',
    ),
    Step(
      'Run the rounds',
      'Start the game when the room is ready. Questions '
          'reveal themselves when the clock runs out, and you move on to the '
          'leaderboard and the cut.',
    ),
    Step(
      'Handle ties and rescues',
      'If players tie at the cut-off, the '
          'faster answers survive. You also get one wildcard to bring a '
          'knocked-out player back.',
    ),
    Step(
      'Finish the night',
      'Run the buzzer final, then show the podium and '
          'who backed the winner.',
    ),
  ];

  static const rules = [
    Step(
      'Bottom 30%',
      'The lowest 30% of the leaderboard go home after '
          'every round.',
    ),
    Step(
      'Auto-scaled',
      'Each cut is sized so any room size reaches the '
          'finalists in the rounds you pick.',
    ),
    Step(
      'Sudden death',
      'A wrong or missed answer knocks you out on the '
          'spot.',
    ),
  ];

  static const knockedOutTitle = 'Knocked out? Keep playing.';
  static const knockedOut =
      'Knocked-out players keep answering for a shadow score, then back a '
      'finalist before the buzzer round. Nobody sits out the rest of the '
      'night.';

  static const guide = [
    GuideCard('Before the game', 'Set up the room', [
      'A laptop connected to a projector or a large TV, with the browser in '
          'full screen.',
      'Check that players’ phones can open this site on the venue’s Wi‑Fi '
          'or mobile data.',
      'Dim the lights near the screen so the room code is readable from the '
          'back.',
      'The host screen stays awake for the whole game.',
    ]),
    GuideCard('Questions', 'Choose the game', [
      'Questions come from the built-in question bank for now.',
      'Typing a topic and getting AI-written questions is coming soon.',
      'Pick 3, 5, 8 or 10 questions a round and 15, 20 or 30 seconds each.',
      'Choose 2, 3 or 4 finalists for the buzzer final.',
    ]),
    GuideCard('During the game', 'Keep the pace', [
      'Wait for the joined count to stop rising before you start.',
      'Turn “Question on phones” off to make everyone look up at the big '
          'screen.',
      'Pause between rounds to read out who survived; the screen does the '
          'drama.',
      'Use your one wildcard to rescue a knocked-out player.',
    ]),
    GuideCard('If something goes wrong', 'Troubleshooting', [
      'A player dropped out: they reopen the site on the same phone and go '
          'straight back in with their score.',
      '“This game session doesn’t exist”: check the four digits on the big '
          'screen.',
      '“The game has already started”: late joiners can join the next game.',
      'The host screen fits any screen, from a projector to a phone.',
    ]),
  ];

  static const faq = [
    FaqGroup('Players', [
      Faq(
        'Do players need to download an app?',
        'No. Quiz Night runs in '
            'the phone’s web browser. Scan the QR on the big screen, or open '
            'this site and enter the room code.',
      ),
      Faq(
        'Do players need an account?',
        'No. Players only enter a room code '
            'and a nickname.',
      ),
      Faq(
        'What if my phone loses connection?',
        'Reopen the site on the same '
            'phone. You go straight back into the game with your answers and '
            'score.',
      ),
      Faq(
        'I was knocked out. Can I still play?',
        'Yes. You keep answering '
            'for a shadow score and back a finalist before the final.',
      ),
    ]),
    FaqGroup('Hosts', [
      Faq(
        'Do I need an account to host?',
        'No. Open the site on a laptop and '
            'tap “Host a game”.',
      ),
      Faq(
        'Can I write my own questions?',
        'Not yet. Games use the built-in '
            'question bank. Your own questions and AI-written ones are '
            'coming.',
      ),
      Faq(
        'What equipment do I need?',
        'A laptop or computer connected to a '
            'projector or a large screen, and an internet connection.',
      ),
      Faq(
        'How is a tie at the cut-off decided?',
        'The players who answered '
            'correctly faster survive.',
      ),
    ]),
    FaqGroup('Privacy', [
      Faq(
        'What do you store about players?',
        'Only the nickname they type '
            'and their answers and scores for the game they play. No names, '
            'emails or phone numbers.',
      ),
    ]),
  ];

  static const footerTagline = 'The live elimination quiz for any crowd.';
}

/// A numbered step: a short title and a sentence or two.
class Step {
  final String title;
  final String detail;

  const Step(this.title, this.detail);
}

class GuideCard {
  final String kicker;
  final String title;
  final List<String> items;

  const GuideCard(this.kicker, this.title, this.items);
}

class Faq {
  final String question;
  final String answer;

  const Faq(this.question, this.answer);
}

class FaqGroup {
  final String name;
  final List<Faq> items;

  const FaqGroup(this.name, this.items);
}
