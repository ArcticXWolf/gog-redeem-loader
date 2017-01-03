# Loader for the GOG redeem website

The GOG redeem website (https://gog.com/redeem) is a pain to search in.
All games are listed in random order, on multiple pages and there are no search fields or filters.

This ruby script loads all game information of the redeem website and outputs them, so you can search them quickly.
It shows the the page number, where the game is displayed on and then you can redeem it on the official page.

## Prerequisites

You only need to have ruby installed on your system. It was tested with ruby 2.3.1.
Then copy the script into a location you have read and write permissions and you are good to go,

## Usage

First you need to go to the redeem page and once solve the captcha there.
Then execute the script via command line:

```
ruby gog-redeem-loader.rb -c CODE
```

You need to specify at least the option "-c", as the script will need your redeem code to only load the games you are allowed to choose from.

For other options run
```
ruby gog-redeem-loader.rb -h
```

## Examples

### Search for specific title

```
$ ruby gog-redeem-loader.rb -c CODE -n Baphomet
Page   Name
4      Baphomets Fluch II: Die Spiegel der Finsternis 
14     Baphomets Fluch: Der Engel des Todes 
4      Baphomets Fluch: Der schlafende Drache 
11     Baphomets Fluch: The Director's Cut 
```

So we know the "Baphomets Fluch" games are on pages 4, 11 and 14.

### Print all games sorted alphabetically
```
$ ruby gog-redeem-loader.rb -c CODE
```

### Print all games sorted by price
```
$ ruby gog-redeem-loader.rb -c CODE -s price
```

## Contribute

If you want to contribute to this script, fork this repo, do your changes and issue a pull request. Any help is appreciated. :)
