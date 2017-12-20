## Embroidery Floss Color Scheme Tool
** work in progress **

A web app built with Node.js, MongoDB and Express.

Converting embroidery floss colors between brands is a pain. Finding similar colors that will fit in your color schem by looking through DMC and Anchor color charts is pretty much impossible. This tool aims to solve those problems.

This project is not yet depoloyed. To run locally:
1. Clone this repo
2. Run `npm install`
3. Run `npm start`
4. Ensure mongo running and listening at default port 27017
4. Go to http://localhost:3000/

### Features
#### Search:
Search for an embroidery floss by DMC code, Anchor code, or color name (e.g. "Apricot Very Light"). See results that match codes exactly as entered and all matching name results. Entering "Apricot" would return "Apricot Very Light", "Apricot Light", "Apricot", and "Apricot Medium".

#### Color Scheme:
Add/remove colors to your color scheme and to see how they look together.

#### Similar Colors:
See a range of the 5 closest colors to an embroidery thread. It is super annoying to drive to the craft store all for a 30 cent blob of embroidery thread, when you probably had something close enough at home. Closeness is calculated by red, green, and blue factors of the color's digital representation. It is not the most scientifically accurate method of determining color closeness, but it's better than guessing!

*Remember that the color you see on your computer screen may be different than the color on my computer screen, and is certainly different than thread colors in real life (which are deeper and more dimensional, yay!). But, hopefully comparing the digital representations of thread colors with each other will still be super helpful.*
