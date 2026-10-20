/// A question template; copied into the `question` table when played.
class BankQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;

  const BankQuestion(this.text, this.options, this.correctIndex);
}

/// Questions for the elimination rounds.
const roundQuestions = <BankQuestion>[
  BankQuestion('What is the chemical symbol for gold?', [
    'Go',
    'Gd',
    'Au',
    'Ag',
  ], 2),
  BankQuestion('How many continents are there?', ['5', '6', '7', '8'], 2),
  BankQuestion('Which planet is known as the Red Planet?', [
    'Venus',
    'Mars',
    'Jupiter',
    'Mercury',
  ], 1),
  BankQuestion('What is the largest ocean on Earth?', [
    'Atlantic',
    'Indian',
    'Arctic',
    'Pacific',
  ], 3),
  BankQuestion('Who wrote "Romeo and Juliet"?', [
    'Charles Dickens',
    'William Shakespeare',
    'Jane Austen',
    'Mark Twain',
  ], 1),
  BankQuestion('What is the boiling point of water at sea level in °C?', [
    '90',
    '100',
    '110',
    '120',
  ], 1),
  BankQuestion('How many sides does a hexagon have?', ['5', '6', '7', '8'], 1),
  BankQuestion('Which gas do plants absorb from the air for photosynthesis?', [
    'Oxygen',
    'Nitrogen',
    'Carbon dioxide',
    'Hydrogen',
  ], 2),
  BankQuestion('What is the capital of Japan?', [
    'Osaka',
    'Kyoto',
    'Tokyo',
    'Nagoya',
  ], 2),
  BankQuestion('What is 12 × 12?', ['124', '144', '132', '156'], 1),
  BankQuestion('Which is the longest river in Africa?', [
    'Congo',
    'Niger',
    'Zambezi',
    'Nile',
  ], 3),
  BankQuestion('What is the hardest natural substance?', [
    'Gold',
    'Iron',
    'Diamond',
    'Quartz',
  ], 2),
  BankQuestion('How many bones are in the adult human body?', [
    '186',
    '206',
    '226',
    '256',
  ], 1),
  BankQuestion('Which organ pumps blood around the body?', [
    'Liver',
    'Lungs',
    'Heart',
    'Kidney',
  ], 2),
  BankQuestion('What is the smallest prime number?', ['0', '1', '2', '3'], 2),
  BankQuestion('In which country are the pyramids of Giza?', [
    'Mexico',
    'Egypt',
    'Peru',
    'Sudan',
  ], 1),
  BankQuestion('What is the capital of Nigeria?', [
    'Lagos',
    'Abuja',
    'Kano',
    'Ibadan',
  ], 1),
  BankQuestion('Which planet is closest to the Sun?', [
    'Venus',
    'Earth',
    'Mercury',
    'Mars',
  ], 2),
  BankQuestion('What is the freezing point of water in °F?', [
    '0',
    '32',
    '50',
    '100',
  ], 1),
  BankQuestion('Who painted the Mona Lisa?', [
    'Michelangelo',
    'Raphael',
    'Leonardo da Vinci',
    'Donatello',
  ], 2),
  BankQuestion(
    'How many players are on a football (soccer) team on the pitch?',
    ['9', '10', '11', '12'],
    2,
  ),
  BankQuestion('What is the square root of 81?', ['7', '8', '9', '10'], 2),
  BankQuestion('Which language has the most native speakers?', [
    'English',
    'Spanish',
    'Mandarin Chinese',
    'Hindi',
  ], 2),
  BankQuestion('What is H2O more commonly known as?', [
    'Salt',
    'Water',
    'Hydrogen peroxide',
    'Oxygen',
  ], 1),
  BankQuestion('Which animal is the largest mammal?', [
    'African elephant',
    'Blue whale',
    'Giraffe',
    'Hippopotamus',
  ], 1),
  BankQuestion('What is the main language spoken in Brazil?', [
    'Spanish',
    'Portuguese',
    'French',
    'English',
  ], 1),
  BankQuestion('How many minutes are in a day?', [
    '1,240',
    '1,440',
    '1,640',
    '2,400',
  ], 1),
  BankQuestion('Which shape has three sides?', [
    'Square',
    'Triangle',
    'Pentagon',
    'Circle',
  ], 1),
  BankQuestion('What is the capital of Kenya?', [
    'Mombasa',
    'Kampala',
    'Nairobi',
    'Kisumu',
  ], 2),
  BankQuestion('Which vitamin does the skin make in sunlight?', [
    'Vitamin A',
    'Vitamin B12',
    'Vitamin C',
    'Vitamin D',
  ], 3),
  BankQuestion('What do bees make?', ['Milk', 'Honey', 'Silk', 'Wax only'], 1),
  BankQuestion('What is the tallest mountain above sea level?', [
    'K2',
    'Kilimanjaro',
    'Everest',
    'Mont Blanc',
  ], 2),
  BankQuestion('Which is a primary colour of light?', [
    'Yellow',
    'Green',
    'Purple',
    'Orange',
  ], 1),
  BankQuestion('What is 15% of 200?', ['15', '20', '30', '35'], 2),
  BankQuestion('What is the currency of the United Kingdom?', [
    'Euro',
    'Pound sterling',
    'Dollar',
    'Franc',
  ], 1),
  BankQuestion('Which part of the plant conducts photosynthesis most?', [
    'Roots',
    'Stem',
    'Leaves',
    'Flowers',
  ], 2),
  BankQuestion('How many hours are in a week?', [
    '148',
    '156',
    '168',
    '172',
  ], 2),
  BankQuestion('Who developed the theory of relativity?', [
    'Isaac Newton',
    'Albert Einstein',
    'Nikola Tesla',
    'Galileo Galilei',
  ], 1),
  BankQuestion('What is the largest planet in our solar system?', [
    'Saturn',
    'Jupiter',
    'Neptune',
    'Earth',
  ], 1),
  BankQuestion('Which metal is liquid at room temperature?', [
    'Lead',
    'Mercury',
    'Tin',
    'Zinc',
  ], 1),
];

/// Harder questions for the buzzer final.
const finalQuestions = <BankQuestion>[
  BankQuestion('What is the atomic number of carbon?', [
    '4',
    '6',
    '8',
    '12',
  ], 1),
  BankQuestion('In which year did World War II end?', [
    '1918',
    '1939',
    '1945',
    '1950',
  ], 2),
  BankQuestion('What is the capital of Australia?', [
    'Sydney',
    'Melbourne',
    'Canberra',
    'Perth',
  ], 2),
  BankQuestion('Which element has the chemical symbol "Fe"?', [
    'Fluorine',
    'Iron',
    'Lead',
    'Francium',
  ], 1),
  BankQuestion('What is the value of π to two decimal places?', [
    '3.12',
    '3.14',
    '3.16',
    '3.41',
  ], 1),
  BankQuestion('Which scientist proposed the three laws of motion?', [
    'Kepler',
    'Newton',
    'Darwin',
    'Faraday',
  ], 1),
  BankQuestion('What is the powerhouse of the cell?', [
    'Nucleus',
    'Ribosome',
    'Mitochondrion',
    'Golgi apparatus',
  ], 2),
  BankQuestion('How many degrees are in the interior angles of a triangle?', [
    '90',
    '180',
    '270',
    '360',
  ], 1),
  BankQuestion('Which country has the largest land area?', [
    'Canada',
    'China',
    'USA',
    'Russia',
  ], 3),
  BankQuestion('What is the speed of light, approximately, in km/s?', [
    '3,000',
    '30,000',
    '300,000',
    '3,000,000',
  ], 2),
  BankQuestion('What is 2 to the power of 10?', [
    '512',
    '1,000',
    '1,024',
    '2,048',
  ], 2),
  BankQuestion('Which blood type is the universal red-cell donor?', [
    'A+',
    'AB+',
    'O−',
    'B−',
  ], 2),
];
