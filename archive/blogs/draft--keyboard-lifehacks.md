# Web Developers Life Hacks

When it comes to multitasking, often the role of web-developer is put to
the limit. Specially when you are Full Stack developer in startup
environment or a smaller company where is counter productive to
specialize. We are often asked to work on back-end, front-end, do deployments, run
tests, do code reviews, and answer to important email at the same time.

There has been lot of [research][4] done on how humans do multitasking and basically
we don't. Our brain can really do only one thing effective. Yes we can
listen music and still do Math, but we cannot teach ourself Math and
Spanish at the same time.

That's why I like adjust my work environment in a way that helps my
brain do least amount of work to switch between multiple tasks.

This article will be about some of the techniques / life-hacks I use in daily base.


## All about keeping your eyes on the screen

> fallowing 2 paragraphs I  have no study or research to point to, I's just the
> experiments I'm doing over several years on myself. If you find that
> you disagree with me, please feel free to ignore them.


The true key towards productivity is to do everything in order to keep
your eyes on the screen. Think about it. When you are typing with  2 / 3
fingers you need to look from time to time on the keyboard whether you are hitting the
correct keys. The time to locate the position of the line is quick, but
still it's extra uncesarry work for your eyes and brain that's adds up
by end of the day.

Lot of time I see people worknig on two or three monitors where on one
screen they have console on other logs on other browser, ... I was using
similar setup year or two myself and the biggest problem I found in it
was that in order to switch context I needed to actually **turn my
head**.

Now this sounds really stupid but think about it. In order to switch
from console to logs you need to turn your head then use your eyes to
find the line and then start processing the information. When you want
to go back to console you need to turn your head, adjust eyes,  find
information, and so on..., There is unecesary element of mechanical neck
movement.

> Try this yourself. Plug in for several minutes external screen where on one window you will have
> only editor, and in another monitor console. Then after time is up try
> it on one monitor (same workspace) lunch only console and Rails logs
> and use only Alt+Tab to switch between them. Which one feels more
> natural for you?

Now two /three monitors may be awesome or even necesary for designers working in
Photoshop or 3Ds Max. My girlfriend is a 3D modeler and from countless
weekends I was watching her working in her enviroment and how everything
has it's place. more bigger  screen she has the more productive she is.

But web developers spend most of time solving issues in text editors
We don't have to have different tabs for special tools.

> Few honorable exception I found over the years where it make sence to
> have two screens:
>
> * if develpors do  UX design or, Photoshop mockups allong code
> * full IDEs like Eclipse, RubyMine, Netbeans, ...
> * if you write Cucumber tests (Gerkin lang) in one screen and step definitions in other
>   screen

We usually fallow programming conventions (like [ruby style guide][13])
that guides us to use 80 or so chars per line as a limit, so that our
code is readable to all our collegues and on Github.

In my opinion external screens when used as the only screen are not needed as well.
I like to use them whenever possible as larger text means less struggle for the eyes
but there is a sort of elegance in writing text on a smaller screen. You
will be pusshed to focuse on one thing, you will be pusshed to close
any background  appplications that are not necesary needed for the
current task. Another point is that you will get use to same screen as
you have when you code in sofa, train, or coffee shop.
If you are a person who codes only on office table none of the points I
made in this paragraph may not be relevant for you.

It's really up to you to try out what works for you and figure these for
your self.

But if we don't use two screens how can we be sill productive ?

## Workspaces

Workspaces (or sometime refernced as "Desktops") are your visual
enviromne........

In sort of extension we all are familiar with `Alt+Tab` combination
(switch to other application). Now imagine you need for your work
WebBrowser where you run the web application you are developing, Rails
console to debug, another console where you run test and text editor.
That is 4 applications that means on one workspace that means pressing
up to 4 times `Alt+Tab` combination

Now imagine a boss ask's you to `ssh` to server and to reply to
important email. That's extra 2. Some of us would be tempted just to
close some of the applications we not necesserally need in order to
complete the task, but let's be realistic, you were working on this
piece of code since morning, you don't want to reopen all the editor
tabs, and in Rails console you are in middle of writing a object on the
fly. Therefore you chose to open 2 more apps and than just deal with 6
`Alt+tabs` 

All of us experienced how this go out of hand.

Now imagine that we will add extra workspace where we would keep the
stuff we were working on, and we would do the stuff that boss asked us.

Now this is more productive. But this goes out of control really easy
and soon we loose track of what is on what workspace. That is the main
point that OperatingSystems removed workspaces from default setup, as
users were complaining that they cannot find their applications.

Now Imagine you will not use 2 workspaces but you would use 6 (3 columns
in 2 rows). Now imagine you will make a contract with yourself that you
will have ideally 2, max 3 windows and on particilar workspaces you will
have only certain usage scope of applications. For example

* workspace 1: Browser with `localhost:3000`, and Rails server / log
* workspace 2: Editor, Rails console, console to run tests
* workspace 3: Comunication tools with your collegues (Slack, email
               client, browser with work Gmail,...)
* workspace 4: ssh connection to app server
* workspace 5: personal stuff, music, personal Gmail, ..
* workspace 6: everything else

Now in every workspace you will press ideally 2, max 3 times `Alt+Tab`
to get your stuff done.

Key here is not to think about the work spaces in numbers, but imagine
them in space; table of 3 cols in 2 rows.

    |  workspace 1  |  workspace 2 | workspace 3 |
    |  workspace 4  |  workspace 5 | workspace 6 |

Therefore you don't think about `"I need to test my localhost in
workspace 1 and turn of music in Workspace 5"` but you imagine `"I have my localhost browser in top-left"`

In terms of switching between workspaces you
will configure keybord shortcuts that would be easily accessable.
Because the previous section was about Ten Finger Typing Technique we
will assume you are typing with 10 fingers. 
Best accessible numbers for 10 finger technique are 1,2 3, 0, 9, 8 as
they are easily reachable, therefore we will configure this shortcuts:

* workspace 1: `ctrl + 1`
* workspace 2: `ctrl + 2`
* workspace 3: `ctrl + 3`
* workspace 4: `ctrl + 8`
* workspace 5: `ctrl + 9`
* workspace 6: `ctrl + 0`



in ubuntu go to `Apperance` click tab `Behavior` and click checkbox
`enable workspaces`




# Standing descs

Expedit standing desk by Peter Marks, Portland, OR ([source][17], [source][14])

![Expedit standing desk by Peter Marks, Portland](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/expedit-standing-desk.jpg)

Here you can see Jessica Allen's (Engine Yard) implementation of
Standing Desk ([Jessica's blog post on Standing Desk][16]) 

I recommend to check [this blog post][15] for more ideas for home made
standing desk ideas.




[1]: vim
[2]: https://github.com/equivalent/scrapbook2/blob/master/archive/web-developer-productivity/ep-1-split-keyboards.md
[3]: https://en.wikipedia.org/wiki/Soldering
[4]: https://en.wikipedia.org/wiki/Human_multitasking#The_brain.27s_role
[5]: https://en.wikipedia.org/wiki/Dvorak_Simplified_Keyboard
[6]: https://en.wikipedia.org/wiki/Dvorak_Simplified_Keyboard#History
[7]: http://www.kaufmann.no/roland/dvorak/
[8]: emacs
[9]: sublime
[10]: vim resources
[11]: vim resources
[12]: https://github.com/carlhuda/janus
[13]: https://github.com/bbatsov/ruby-style-guide
[14]: http://www.ikeahackers.net/2011/04/expedit-standing-desk.html
[15]: http://www.homedit.com/ikea-standing-desk/
[16]: http://spacekat.me/blog/2012/07/26/diy-standing-desk/
[17]: http://petermarks.info/2011/04/11/the-spaceship-2-0/
[18]: qwerty keyborad wikipedia



[101]: https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/ten-finger-typing.png 'Original Wikipedia'
[102]: https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/dvorak-layout.png

Image sources

* [Standing Desk ergonomics img](http://fitness.stackexchange.com/questions/9660/proper-ergonomics-for-a-standing-desk)
* [Standing Desk ideas imgs](http://www.homedit.com/ikea-standing-desk/)























