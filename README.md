# Hum

Hum generates HTML from your SASS or CSS.

`gem install hum`

Here's an example of what he can do:

    #He'll eat this CSS
    .foo{
      border-width: 1px;
    }
    .foo .bar{
      font-size: 12px;
    }
    .foo .bar p{
      color: black;
    }

    #And crap out this HTML
    <div class="foo">
      <div class="bar">
        <p></p>
      </div>
    </div>

To do that run

`hum [stylesheet].css`

You can also watch a directory for changes by using

`hum --watch`

He can't generate HTML from SASS directly yet, so you must specify a CSS file.