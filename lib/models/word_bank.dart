import 'sight_word.dart';

/// Oxford Wordlist — the official high-frequency word list used in
/// Australian primary schools (Prep/Foundation through Year 2).
///
/// Based on research by Oxford University Press Australia analysing
/// children's writing samples. 307 words across 12 lists, ordered
/// by frequency of use. Lists 1-4 are Prep/Foundation level,
/// 5-8 are Year 1, 9-12 are Year 2.
class WordBank {
  static const List<List<String>> _levelWords = [
    // List 1 — Most frequent (Prep)
    ['the', 'I', 'a', 'to', 'and', 'my', 'is', 'it', 'was', 'in',
     'she', 'of', 'we', 'he', 'me', 'at', 'on', 'went', 'am', 'then',
     'said', 'had', 'go', 'up', 'so'],

    // List 2 (Prep)
    ['got', 'like', 'with', 'are', 'but', 'for', 'her', 'his', 'that',
     'they', 'this', 'do', 'you', 'not', 'be', 'out', 'all', 'one',
     'were', 'when', 'have', 'him', 'no', 'them', 'or'],

    // List 3 (Prep)
    ['mum', 'play', 'some', 'home', 'see', 'did', 'there', 'come', 'big',
     'can', 'day', 'get', 'has', 'down', 'dad', 'an', 'our', 'would',
     'could', 'from', 'back', 'will', 'dog', 'what', 'ran'],

    // List 4 (Prep)
    ['just', 'little', 'into', 'time', 'look', 'came', 'school', 'after',
     'very', 'off', 'because', 'two', 'put', 'if', 'fun', 'good', 'house',
     'been', 'water', 'by', 'about', 'too', 'saw', 'their', 'going'],

    // List 5 (Year 1)
    ['made', 'over', 'first', 'name', 'new', 'eat', 'friend', 'swim',
     'ball', 'old', 'ride', 'find', 'told', 'cat', 'car', 'next', 'long',
     'love', 'boy', 'fell', 'live', 'now', 'say', 'make', 'want'],

    // List 6 (Year 1)
    ['tree', 'started', 'girl', 'other', 'bed', 'people', 'brother',
     'once', 'only', 'three', 'man', 'run', 'upon', 'stop', 'sister',
     'bike', 'park', 'than', 'stay', 'last', 'fast', 'today', 'called',
     'fish', 'jump'],

    // List 7 (Year 1)
    ['night', 'still', 'sad', 'here', 'lot', 'nice', 'sun', 'end',
     'how', 'oh', 'pool', 'where', 'away', 'kill', 'money', 'played',
     'year', 'bad', 'king', 'lost', 'crash', 'thing', 'much', 'who',
     'as'],

    // List 8 (Year 1)
    ['family', 'really', 'woke', 'won', 'help', 'us', 'fly', 'found',
     'game', 'took', 'food', 'give', 'sleep', 'start', 'fire', 'door',
     'four', 'happy', 'head', 'know', 'let', 'need', 'best', 'keep',
     'children'],

    // List 9 (Year 2)
    ['walk', 'white', 'work', 'write', 'take', 'town', 'try', 'turn',
     'under', 'tell', 'should', 'show', 'side', 'sit', 'think',
     'round', 'same', 'sat', 'save', 'through', 'read', 'red', 'right',
     'inside', 'pick'],

    // List 10 (Year 2)
    ['each', 'even', 'every', 'eye', 'face', 'far', 'feel', 'felt',
     'kid', 'knew', 'land', 'left', 'life', 'light', 'line',
     'looking', 'miss', 'more', 'morning', 'most', 'mother', 'must',
     'never', 'open', 'own'],

    // List 11 (Year 2)
    ['part', 'party', 'place', 'pull', 'push', 'race', 'rain', 'road',
     'room', 'black', 'blue', 'book', 'box', 'bring', 'bus', 'buy',
     'catch', 'class', 'cool', 'cup', 'cut', 'dark', 'grow', 'hard',
     'hat'],

    // List 12 (Year 2)
    ['hear', 'high', 'hit', 'hope', 'hot', 'hurt', 'idea', 'many',
     'may', 'sea', 'set', 'small', 'something', 'sometimes', 'soon',
     'sport', 'stand', 'story', 'suddenly', 'world', 'wish', 'yes',
     'use', 'number', 'great'],
  ];

  static List<SightWord> getAllWords() {
    final words = <SightWord>[];
    for (var level = 0; level < _levelWords.length; level++) {
      for (final word in _levelWords[level]) {
        words.add(SightWord(word: word, level: level + 1));
      }
    }
    return words;
  }

  static List<SightWord> getWordsForLevel(int level) {
    if (level < 1 || level > _levelWords.length) return [];
    return _levelWords[level - 1]
        .map((w) => SightWord(word: w, level: level))
        .toList();
  }

  static int get totalLevels => _levelWords.length;
  static int get totalWords =>
      _levelWords.fold(0, (sum, list) => sum + list.length);

  /// Level names matching Australian school structure.
  static String levelName(int level) {
    if (level <= 4) return 'Prep List $level';
    if (level <= 8) return 'Year 1 List ${level - 4}';
    return 'Year 2 List ${level - 8}';
  }

  /// Example sentences for words (used in sentence activities).
  /// Target word is wrapped in underscores: _word_
  static const Map<String, String> sentences = {
    // List 1
    'the': 'Look at _the_ dog.',
    'I': '_I_ like to play.',
    'a': 'I have _a_ cat.',
    'to': 'I want _to_ go.',
    'and': 'Mum _and_ Dad.',
    'my': 'This is _my_ book.',
    'is': 'He _is_ happy.',
    'it': 'I like _it_.',
    'was': 'She _was_ here.',
    'in': 'The cat is _in_ the box.',
    'she': '_She_ is kind.',
    'of': 'A cup _of_ water.',
    'we': '_We_ can play.',
    'he': '_He_ is tall.',
    'me': 'Come with _me_.',
    'at': 'Look _at_ me.',
    'on': 'Sit _on_ the chair.',
    'went': 'We _went_ to the park.',
    'am': 'I _am_ five.',
    'then': 'And _then_ we ran.',
    'said': 'Mum _said_ yes.',
    'had': 'I _had_ fun.',
    'go': 'Let\'s _go_ home.',
    'up': 'Stand _up_ please.',
    'so': 'I am _so_ happy.',

    // List 2
    'got': 'I _got_ a star.',
    'like': 'I _like_ apples.',
    'with': 'Come _with_ me.',
    'are': 'They _are_ here.',
    'but': 'I tried _but_ I fell.',
    'for': 'This is _for_ you.',
    'her': 'I gave _her_ a hug.',
    'his': 'That is _his_ hat.',
    'that': 'I know _that_ word.',
    'they': '_They_ went home.',
    'this': 'I like _this_ one.',
    'do': 'What _do_ you want?',
    'you': 'I see _you_!',
    'not': 'I am _not_ sad.',
    'be': 'I want to _be_ good.',
    'out': 'Go _out_ and play.',
    'all': 'We _all_ went.',
    'one': 'I have _one_ apple.',
    'were': 'They _were_ happy.',
    'when': '_When_ is lunch?',
    'have': 'I _have_ two cats.',
    'him': 'I saw _him_.',
    'no': '_No_ thank you.',
    'them': 'Give it to _them_.',
    'or': 'Yes _or_ no?',

    // List 3
    'mum': '_Mum_ is great.',
    'play': 'Let\'s _play_ outside.',
    'some': 'Have _some_ water.',
    'home': 'Let\'s go _home_.',
    'see': 'I can _see_ you.',
    'did': 'I _did_ my best.',
    'there': 'Over _there_!',
    'come': '_Come_ and look.',
    'big': 'A _big_ bear.',
    'can': 'I _can_ do it.',
    'day': 'What a nice _day_.',
    'get': 'I will _get_ it.',
    'has': 'He _has_ a dog.',
    'down': 'Sit _down_ here.',
    'dad': '_Dad_ is funny.',
    'an': 'I ate _an_ apple.',
    'our': 'This is _our_ house.',
    'would': 'I _would_ like that.',
    'could': 'I _could_ try.',
    'from': 'A gift _from_ Dad.',
    'back': 'Come _back_ soon.',
    'will': 'I _will_ try.',
    'dog': 'The _dog_ is brown.',
    'what': '_What_ is that?',
    'ran': 'He _ran_ fast.',

    // List 4
    'just': 'I _just_ got here.',
    'little': 'A _little_ bird.',
    'into': 'Jump _into_ the pool.',
    'time': 'What _time_ is it?',
    'look': '_Look_ at the sky.',
    'came': 'She _came_ over.',
    'school': 'I love _school_.',
    'after': '_After_ school.',
    'very': 'I am _very_ glad.',
    'off': 'Take it _off_.',
    'because': 'I\'m happy _because_ it\'s sunny.',
    'two': 'I have _two_ hands.',
    'put': '_Put_ it down.',
    'if': 'I wonder _if_ I can.',
    'fun': 'That was _fun_!',
    'good': 'That was _good_.',
    'house': 'A big _house_.',
    'been': 'I have _been_ there.',
    'water': 'I drink _water_.',
    'by': 'Sit _by_ me.',
    'about': 'Tell me _about_ it.',
    'too': 'Me _too_!',
    'saw': 'I _saw_ a bird.',
    'their': '_Their_ dog is big.',
    'going': 'I am _going_ out.',

    // List 5
    'made': 'Mum _made_ a cake.',
    'over': 'Jump _over_ it.',
    'first': 'I was _first_!',
    'name': 'My _name_ is Ben.',
    'new': 'I got a _new_ toy.',
    'eat': 'Let\'s _eat_ lunch.',
    'friend': 'She is my _friend_.',
    'swim': 'I can _swim_.',
    'ball': 'Kick the _ball_.',
    'old': 'My _old_ shoes.',
    'ride': 'I can _ride_ a bike.',
    'find': 'Help me _find_ it.',
    'told': 'Mum _told_ me.',
    'cat': 'The _cat_ is asleep.',
    'car': 'A red _car_.',
    'next': 'What is _next_?',
    'long': 'A _long_ day.',
    'love': 'I _love_ you.',
    'boy': 'The _boy_ ran.',
    'fell': 'I _fell_ over.',
    'live': 'I _live_ here.',
    'now': 'Do it _now_.',
    'say': 'What did you _say_?',
    'make': 'Let\'s _make_ something.',
    'want': 'I _want_ to go.',

    // List 6
    'tree': 'A big _tree_.',
    'started': 'We _started_ to run.',
    'girl': 'The _girl_ smiled.',
    'other': 'The _other_ one.',
    'bed': 'Go to _bed_.',
    'people': 'Lots of _people_.',
    'brother': 'My _brother_ is little.',
    'once': '_Once_ upon a time.',
    'only': 'I have _only_ one.',
    'three': 'I am _three_... no, five!',
    'man': 'The _man_ waved.',
    'run': 'I can _run_ fast.',
    'upon': 'Once _upon_ a time.',
    'stop': '_Stop_ the car.',
    'sister': 'My _sister_ is nice.',
    'bike': 'I ride my _bike_.',
    'park': 'We went to the _park_.',
    'than': 'I am bigger _than_ you.',
    'stay': '_Stay_ here.',
    'last': 'The _last_ one.',
    'fast': 'He is very _fast_.',
    'today': 'I am happy _today_.',
    'called': 'Mum _called_ me.',
    'fish': 'A big _fish_.',
    'jump': 'I can _jump_ high.',

    // List 7
    'night': 'Good _night_!',
    'still': 'Sit _still_.',
    'sad': 'I feel _sad_.',
    'here': 'Come _here_ please.',
    'lot': 'I ate a _lot_.',
    'nice': 'That is _nice_.',
    'sun': 'The _sun_ is out.',
    'end': 'The _end_!',
    'how': '_How_ are you?',
    'oh': '_Oh_ no!',
    'pool': 'I swam in the _pool_.',
    'where': '_Where_ are you?',
    'away': 'Run _away_!',
    'money': 'I found some _money_.',
    'played': 'We _played_ all day.',
    'year': 'I am five years old this _year_.',
    'bad': 'That was _bad_.',
    'king': 'The _king_ sat down.',
    'lost': 'I _lost_ my hat.',
    'crash': 'I heard a _crash_!',
    'thing': 'What is that _thing_?',
    'much': 'Thank you so _much_.',
    'who': '_Who_ is that?',
    'as': 'Not _as_ big.',

    // List 8
    'family': 'I love my _family_.',
    'really': 'I _really_ like it.',
    'woke': 'I _woke_ up early.',
    'won': 'We _won_ the game!',
    'help': 'Can you _help_ me?',
    'us': 'Come with _us_.',
    'fly': 'Birds can _fly_.',
    'found': 'I _found_ it!',
    'game': 'Let\'s play a _game_.',
    'took': 'I _took_ my bag.',
    'food': 'I like _food_.',
    'give': '_Give_ it to me.',
    'sleep': 'Time to _sleep_.',
    'start': 'Let\'s _start_.',
    'fire': 'A warm _fire_.',
    'door': 'Open the _door_.',
    'four': 'I have _four_ toys.',
    'happy': 'I am so _happy_.',
    'head': 'I bumped my _head_.',
    'know': 'I _know_ that word.',
    'let': '_Let_ me try.',
    'need': 'I _need_ help.',
    'best': 'You are the _best_.',
    'keep': '_Keep_ it safe.',
    'children': 'The _children_ played.',

    // List 9
    'walk': 'Let\'s go for a _walk_.',
    'white': 'A _white_ cat.',
    'work': 'Good _work_!',
    'write': 'I can _write_ my name.',
    'take': '_Take_ one each.',
    'try': 'I will _try_.',
    'turn': 'It is my _turn_.',
    'under': '_Under_ the bed.',
    'tell': '_Tell_ me a story.',
    'should': 'You _should_ try.',
    'show': '_Show_ me!',
    'side': 'On this _side_.',
    'sit': '_Sit_ down please.',
    'think': 'I _think_ so.',
    'round': 'We went _round_ the tree.',
    'same': 'We are the _same_.',
    'sat': 'I _sat_ down.',
    'save': '_Save_ it for later.',
    'through': 'Walk _through_ the door.',
    'read': 'I can _read_.',
    'red': 'A _red_ ball.',
    'right': 'That is _right_!',
    'inside': 'Come _inside_.',
    'pick': '_Pick_ one.',

    // List 10
    'each': 'One _each_.',
    'even': 'I _even_ ate the peas.',
    'every': '_Every_ day.',
    'eye': 'I shut my _eye_.',
    'face': 'A happy _face_.',
    'far': 'It is _far_ away.',
    'feel': 'I _feel_ good.',
    'felt': 'I _felt_ happy.',
    'kid': 'I am a _kid_.',
    'knew': 'I _knew_ the word!',
    'land': 'We saw the _land_.',
    'left': 'Turn _left_.',
    'life': 'I love _life_.',
    'light': 'Turn on the _light_.',
    'line': 'Stand in a _line_.',
    'looking': 'I am _looking_ for it.',
    'miss': 'I _miss_ you.',
    'more': 'I want _more_.',
    'morning': 'Good _morning_!',
    'most': 'I like it the _most_.',
    'mother': 'My _mother_ is kind.',
    'must': 'I _must_ go.',
    'never': 'I _never_ give up.',
    'open': '_Open_ the box.',
    'own': 'My very _own_.',

    // List 11
    'party': 'A fun _party_!',
    'place': 'A nice _place_.',
    'pull': '_Pull_ the rope.',
    'push': '_Push_ the door.',
    'race': 'Let\'s have a _race_.',
    'rain': 'I love the _rain_.',
    'road': 'Cross the _road_.',
    'room': 'My _room_ is tidy.',
    'black': 'A _black_ cat.',
    'blue': 'The sky is _blue_.',
    'book': 'I read a _book_.',
    'box': 'A big _box_.',
    'bring': '_Bring_ it here.',
    'bus': 'The _bus_ is here.',
    'buy': 'Let\'s _buy_ it.',
    'catch': '_Catch_ the ball.',
    'class': 'My _class_ is fun.',
    'cool': 'That is _cool_!',
    'cup': 'A _cup_ of water.',
    'cut': 'I _cut_ the paper.',
    'dark': 'It is _dark_ now.',
    'grow': 'Watch it _grow_.',
    'hard': 'I tried _hard_.',
    'hat': 'A red _hat_.',
    'part': 'This _part_ is fun.',

    // List 12
    'hear': 'I can _hear_ you.',
    'high': 'Up _high_.',
    'hit': 'I _hit_ the ball.',
    'hope': 'I _hope_ so.',
    'hot': 'It is _hot_ today.',
    'hurt': 'I _hurt_ my knee.',
    'idea': 'Good _idea_!',
    'many': 'So _many_ stars.',
    'may': 'You _may_ go.',
    'sea': 'The _sea_ is blue.',
    'set': 'Get _set_, go!',
    'small': 'A _small_ bug.',
    'something': 'I see _something_.',
    'sometimes': '_Sometimes_ I sing.',
    'soon': 'See you _soon_.',
    'sport': 'I like _sport_.',
    'stand': '_Stand_ up.',
    'story': 'Tell me a _story_.',
    'world': 'The best in the _world_.',
    'wish': 'I _wish_ I could fly.',
    'yes': '_Yes_ please!',
    'use': 'I can _use_ it.',
    'number': 'Pick a _number_.',
    'great': 'That is _great_!',
  };

  /// Get a sentence for a word, with the target word marked with underscores.
  static String? getSentence(String word) => sentences[word.toLowerCase()] ?? sentences[word];
}
