# Ergonomics and faster typing practices for Web Developers

As with any craft, there comes a natural need to improve our skills in
Web Development methods. We teach ourself new coding patterns, we try
new development tools, new Editors, ...

Yet it feels like WebDevelopers tend to focus too much on Software and
completely ignore the hardware aspect of improvement. By hardware I mean
our keyboards, our pointer devices, desks, and so on.

That's why in this blog we will have a look at few of them.

> **Update** I gave a lightning talk on this topic
> so if you are interested [here is a video][12].

## Typing with Ten Finger Typing Technique

With  Ten Finger Typing Technique  typists are using all fingers to
type. With left pinky on a QWERTY keyboard you type `1, q, a, z`, Left
ring finger `2, w, s, x`, and so on.

!['Ten Finger Typing - hand positions'][101]

When developers type with ten finger technique, we are using the full
potential of our hands and fingers to type.

We:

* move our hand only up and down not side to side - less effort for
  fingers
* type faster (**update**: may not be true [watch research here][13])
* type without looking on a keyboard
* keep our eyes on a text entire time
* less mistakes, less deleting
* more productive editor shortcut execution

When developers type with freestyle typing technique
they are loosing all the above benefits.

One of the biggest arguments against typing with Ten Finger Technique is
that programmers and web-developers too often use special chars like
`{}"'/?\~ <>` usually located on the right side of the keyboard, and
therefore the right small finger (pinky) gets to tired (image above, yellow section).

Well, this is true, however the problem isn't that the typing technique is bad,
the problem is that QWERTY keyboard layout (as any other layout out
there) was designed for different group of people (book writers, newspaper editors, ...)

## Dvorak

The [QWERTY][1] keyboard layout was designed so that the mechanical typewriter won't jam.
Layout designers did consider speed, but speed in terms of
type faster when you don't have to fix typewriter every 4 minutes.

Between 1914-1932 Dr August Dvorak and Wiliam Dealey designed new layout of
keyboard designed for speed and less errors in typing called [Dvorak
Simplifiex Keyboard Layout][2]. In experiments done on typists it was discovered that Dvorak
layout was + 1/3 more effective in speed than QWERTY.

![Dvorak keyboard layout][102]

With your left hand typist type the vowels while his right hand is typing mostly used consonants.

> in 1933  International Commercial Schools
> Contest typing competition QWERTY typists were complaining that they
> were "disconcerted" from the noise of fast typing of Dvorak typists
> [source][3]

Now this design choice brought very
interesting side-effect for web-developers. Some of the special chars (`"'<,>.`) were moved
to the left hand side of the layout. This doesn't solve the right-hand
little finger problem entirely but definitely helps a lot.

The reason why I recommend Dvorak is not necessarily because of typing
speed but because the design is more comfortable to write code on.

There is also a [Programmer Dvorak][4] which suppose to be designed to
even more improve productivity of typing for programmers / software developers
however I'm not recommending it as it's maybe way too different. I've
tried it for a week was not suitable for me, maybe it well be for you.

Usually the question I get from people is: "But where would I buy a
MacBook with Dvorak?". Well, simply you don't have to. If you use 10
finger technique you don't need to see the keys, your brain knows where
the keys are. Sure, you can buy a mechanical keyboard and reposition the key,
but that's not the point. The layout is in your head.

Once again Dvorak is only effective if you are going to use 10 finger
technique. If you are a designer where you do need one hand on the mouse
all the time and you use left hand just for shortcuts,
the Dvorak would not be the best idea in my opinion.

> I'm right handed, I'm not sure how effective is Dvorak for Left handed
> folks, but I bet there is lot of articles if you google them.

### Pair coding argument against Dvorak

One argument against Dvorak I get a lot is that: 

`"For pair coding I want to use same layout as my colegues"`

Well yes that's a valid argument, however the question is what layout we
are talking about? If QWERTY are we talking about `US` or `GB` version
of QWERTY ?.

Here is a photo  of a Belgium keyboard MacBook of my friend / colleague:


!['Belgium Keyboard Layout'][103]

For me argument that "everyone should use EN QWERTY" in a multicultural
City is more than nonsense (I live in London UK).

Now days there are better ways how to pair-code, like using CloudIDE or
SSHing to a common VM or use [tmux][5]


## Split Keyboards

> [Watch my full video on split keyboards](https://youtu.be/sDQ8-LmWbow) on
> YouTube (script can be found [here][6]

I'm a tall dude with wide shoulders. When I'm typing on a keyboard it
feels like all keyboards in the world wer design for much smaller
people. Usually after few hours of working on regular size keyboard my wrists get
into pain. This happens even with more expensive keyboards like Mac has.

There is a chance you've seen some people using ergonomic keyboards
where the layout is split in half and curved on one monolithic board.

![image of ergomonmic keyboard][104]

Ergonomic keyboard are improvement but not enough, plus they are usually
large so they are not good for traveling.

I recommend split keyboards where layout is physically split to two boards,
therefore user can positioned them anyway it's comfortable  for him/her.

![image of split keyboard][105]

Split keyboards are awesome and good to travel with. Problem is that
they are expensive (cheapest around $100). Solution I use and recommend is
just to order two regular travel keyboards and use a USB hub to connect them.
I went even further and I've cut of USB cables and [solder][7] them to USB hub
cables. This way I've end up with $35 Split keyboard that I can use for
pair coding on one computer if needed.


![image of split keyboard before join][106]
![image of my split keyboard][107]


## Vim

When I decided to learn Ten Finger Technique, I was starting to learn
basics of [Vim][11] editor. As if this combination was not hard enough I
thought to myself, hmm how about I teach myself Dvorak too. The
transition was really hard, and for period of 2 weeks I had headaches,
but it was worth it.

Dvorak and Ten Finger Typing Technique comes naturally  together and
Vim is awesome addition to this symphony. Vim is awesome when it
comes to keyboard shortcuts limiting usage of Right Hand Pinky to
minimum. Lot of people will reference Vim to a dinosaur and relique that
only "old Linux Hippies use" but they never used Vim them self, or
if they did they didn't try any extension.

I'm just saying: try Vim for a week, but not with just basics. Learn
split screens, visual selection,  read some tutorials watch some
screencasts, if you are a Ruby Developer install [Janus Vim][8] (collection of cool lib
that will make your Vim proper IDE)


But really if  you decide you want to use  [Emacs][10]
 or [Sublime][9] editor it doesn't really matter, just make sure you
discover all the potential cool shortcuts that will ease your life,
only that way you will truly benefit Dvorak and Ten Finger Typing
Technique.

> In any case be sure to focuse on quality rather than speed. Less errors
> when typing and then improving your speed. Play every morning
> [typeracer](http://play.typeracer.com/)


[1]: https://en.wikipedia.org/wiki/QWERTY
[2]: https://en.wikipedia.org/wiki/Dvorak_Simplified_Keyboard
[3]: https://en.wikipedia.org/wiki/Dvorak_Simplified_Keyboard#History
[4]: http://www.kaufmann.no/roland/dvorak/
[5]: http://collectiveidea.com/blog/archives/2014/02/18/a-simple-pair-programming-setup-with-ssh-and-tmux/
[6]: https://github.com/equivalent/scrapbook2/blob/master/archive/web-developer-productivity/ep-1-split-keyboards.md
[7]: https://en.wikipedia.org/wiki/Soldering
[8]: https://github.com/carlhuda/janus
[9]: https://www.sublimetext.com/
[10]: https://en.wikipedia.org/wiki/Emacs
[11]: https://en.wikipedia.org/wiki/Vim_%28text_editor%29
[12]: https://skillsmatter.com/skillscasts/7455-web-developer-life-hacks
[13]: https://www.youtube.com/watch?v=MhYFRr2gUaw&feature=youtu.be

[101]: https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/ten-finger-typing.png 'Original Wikipedia'
[102]: https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/dvorak-layout.png
[103]: https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/belgium-keyboard.jpg
[104]: https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/ergonomic-keyboard.jpg
[105]: https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/split-keyboard.jpg
[106]: https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/my-split-keyboard.jpg
[107]: https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/my-split-keyboard-2.png
