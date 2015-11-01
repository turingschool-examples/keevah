## The Pivot - Keevahh

Keevahh is a micro-lending platform that allows both lenders and borrowers to interact. Borrowers are able to create a project or loan request and lenders are able to contribute to various projects.

The project specifications can be found [here](https://github.com/turingschool/lesson_plans/blob/master/ruby_03-professional_rails_applications/the_pivot.markdown)

[Find Us Here on Heroku](https://lendkeevahh.herokuapp.com/)

## Working With Data Dumps

### Loading the pre-seeded DB dump

This project includes a rake task to load a pre-seeded
DB dump with all the data you will need. It is currently
stored on Turing's dropbox. To download and import it,
use this rake task:

```
$ rake db:pg_restore
```

### Pushing Data to Heroku

Once you've populated your local DB, you can also push those
records to a heroku instance.

1. Create heroku instance (heroku create)
2. Use `heroku pg:push` to export your local data into
the instance. For example:

```
$ heroku pg:push the_pivot_development DATABASE_URL
```

### Contributor Log

* [Markus Olsen](https://github.com/neslom),
* [Trey Tomlinson](https://github.com/treyx)
* [Valentino Espinoza](https://github.com/xvalentino)

## License

The MIT License (MIT)

Copyright (c) [2015]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
