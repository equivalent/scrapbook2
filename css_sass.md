
# attribute selectors 

    ul li
    ul > li #direct child
    .foo + .foo
    h2 ~ p  #  after first appearenc of h2, p will have this style


##has attribute selector 

    img[alt]  # all tags that have alt tag
    <img src="" alt="ooo'>  #yes
    <img src="">  #no

##has specific attribute selector 

    img[alt=ooo]  # all tags that have alt tag
    <img src="" alt="ooo">  #yes
    <img src="" alt='bbb'>  #no

##hyphen search (slug selector)

    div[class|=widget] # looks for word "widget" separated by hyphen
    <div class="homepage-widget-24"></div>   #yes
    <div class="homepage-widget-12"></div>   #yes
    <div class="homepagewidget12"></div>     #no

##character match search

    div[class*=get] # looks for  "get" 
    <div class="homepage-widget-24"></div>   #yes
    <div class="homepage-widget-12"></div>   #yes
    <div class="homepagewidget12"></div>     #yes

## begin with selector

    a[href^="mailto:"]
    <a href="/foo.html"></a>  #no 
    <a href="mailto:qqq@eq8.eu"></a> #yes

## end with selector

    a[href$="pdf"]
    <a href="/foo.pdf"></a> #yes


## pseudo class selector

### first-child

    p:first-child
    <div> 
      <p>yes</p>
      <p>no</p>
    </div>

note: if you have html comment, IE will recognize that as first child :-\ 

### last-child

    li:last-child

    <div> 
      <ul>
        <li>no</li>
        <li>no</li>
        <li>yes</li>
      </ul>
    </div>

    # but !!!
    <div> 
      <ul>
        <li>no</li>
        <li>no</li>
        <li>no</li>
        <p></p>
      </ul>
    </div>

    #fucked up but yes, it may seems that you saying "the last li",  but  you are actually saying "last child and is div"

note: first child is in IE8 but last-child not 

### nth-child

     tr:nth-child(odd) { /* can be odd, even or equasion */ }

     <table>
        <tr><td>yes</td></tr>
        <tr><td>no</td></tr>
     </table>

     #the equasion
     tr:nth-child(3n)
     3x0 = 0 (no selected)
     3x1 = 3rd element (selected)
     3x2 = 6th element (selected)

     tr:nth-child(3n+1)
     3x0 +1 = 1 (selected)
     3x1 +1 = 4th element (selected)
     3x2 +1 = 7th element (selected)

     tr:nth-child(3n-1)
     3x0 - 1 = 0 
     3x1 - 1 = 2nd element (selected)
     3x2 - 1 = 5th element (selected)


     tr:nth-child(n+5)
     0+5     = 5th element selected
     1+5     = 6th element selected
     2+5     = 7th element selected

     #not suported IE8 and below


### nth-last-child

similar like *nth-child* but starts at the bottom

     div:nth-last-child(3n)


##psudo selectors on form

    input:checked + label
    input[type="text"]:disabled
    input:required
    input:optional
    input:valid
    input:invalid


##not()

    input:not(type="radio"]):not(type="checkbox")
    <input type="email">      #yes
    <input type="checkbox">   #no


## pseudo elements

interestingly pseudo elements (by spec) should be with two colons  `::before`. But because of IE8 where pseudo elements work with single colon `:before` all other major browsers suport both `::` and `:` for pseudo element

### :before and :after

      <element><:before><content><:after></element>

### webkit validation form pseudo element bubbles for html5 form

    ::-webkit-validation-buble
    ::-webkit-validation-buble-top-outer-arrow
    ::-webkit-validation-buble-top-inner-arrow
    ::-webkit-validation-buble-message



## fallback

    #css
    .menu li:last-child{}
    .menu li.last{}

    # jQuery
    $('.menu li:last-child').addClass('last')


or check [IE9.js](http://code.google.com/p/ie7-js/)



sources:

* http://2011.html5tx.com/videos/smith
* http://api.jquery.com/category/selectors/

date: 2012-12-27





