# Ako opravit Flyxbox od Orange

> This TIL blog I'm writing in Slovak language as it affects internet
> service only in Slovakia


Ak ste si zobrali 4G internet Flyxbox od Orange isto casom spozorujete
ze sa Vam neda pripojit na router / internet,  alebo Vas mobilny telefon
vyzaduje "prihlasenie do siete" (Sign in to network)

Tu je riesenie. Treba zmenit DNS zaznamy pre router.


Neni to nic zlozite.

1. Pripojte sa na router (navstivte `http://flyxbox.home` alebo `http://192.168.1.1`) 
2. prihlaste sa ako admin (user: `admin` heslo: `admin` (ak ste si ho nezmenili))
3. Po prihlaseni kliknite na `Advanced` a prejdite na `Network > LAN Setings`
4. Tu v sekci `DHCP Server` zmente zaznam (staci kliknut a pisat):

```
Primary DNS: 0.0.0.0
Secondary DNS: 0.0.0.0
```

... na:


```
Primary DNS: 8.8.8.8
Secondary DNS: 8.8.4.4
```

Problem je ale v tom ze ak vypnete router (alebo vybijete poistky)
musite sa znova prihlasit, a zmenit DNS zaznamy ale tento krat zmente
poradie:


```
Primary DNS: 8.8.4.4
Secondary DNS: 8.8.8.8
```

A ano, budete musiet menit poradie zakazdym co vypnete router.

!['flyxbox DNS records fix'](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2017/flyxbox-fix.png)

To by malo byt vsetko.

## Ako to Funguje

Som povolanim programator nie sietovy technik ale pokusim sa vysvetlit co
sa deje najlepsie ako viem.

Kazda webova stranka ma v
skutocnosti za sebou server (alebo ak nie server tak Load Balancer) ktory ma konkretnu IP
adressu. Napriklad tato stranka `www.eq8.eu` ma adresu `54.246.92.153`
(Heroku server).

To znamena DNS servery su prekladace mien `www.daco.com` na IP adresy.

Orange (alebo vyrobca routeru) prednastavil DNS zaznami na `0.0.0.0` co
znamena ze bere "hocijaky DNS server" vo vysej sieti
[1](https://en.wikipedia.org/wiki/0.0.0.0). Neviem prestne preco to ty
co programovali tento router prednastavili (asi aby router nacital Orange DNS server vzdy ked sa zmeni).

Pointa je ta ze my sme natvrdo nastavili DNS servery od Google
`8.8.8.8` a `8.8.4.4`.

> Ak z nejakeho dovodu preferujete ine DNS servery tak ich kludne zmente.

Po restarte routera sa neviem preco router ako keby zasekne a asi
nenacita DNS servery (asi nieco s cache). Tym ze vymenime poradie sa as
dropne cache a znova zacne fungovat.

Ako vravim neviem ci to co pisem je pravda, Len predpokladam ze toto je
problem z toho co som spozoroval (a za 13 rokov hoby nastavovania routerov
 som sa naucil). Preto ak tento clanok cita niekto kto sa
do toho vyzna viac a ma lepsie vysvetlenie prosim hodte mi koment alebo
PullRequest na edit clanku (kedze je na Github).

## Bonus

* pre tych co byvaju v miestach s dobrym pokrytim 4G signalu odporucam
  prepnut "vyberat siet Auto" na "iba 4G" tym donutite router nepripajat
  sa na 3G alebo 2G a budete cerpat iba rychlu siet. Zdoraznujem ale ze
  toto sa oplati iba ak mate 3 aleb 4 palicky signalu na routry, menej
  nie.
* prejdite cely dom/byt a umiestnujte router tam kde vam zasvieti
  najviac paliciek. Ale odporucam skusat to len po tom co nastavite "iba 4G"
  kedze 4 palicky Vam moze ukazat ked bude router prepnuty automaticky
  na 3G
* ak viete po anglicky odporucam pozriet toto video
  https://www.youtube.com/watch?v=cNfCFuh1ukg ujo tam vysvetli vela
  trikov ako umiestnit / nastavit dual-band router tak aby bol WiFi
  signal co  najlepsie dostupny vo vasom dome.


