# Hum

Hum generates HTML from your SASS, SCSS or CSS.

`gem install hum`

## SASS to HTML

`hum [stylesheet].sass`

		#He'll eat this SASS
		.foo
			color: white
			.bar
				color: black
				.baz
					color: red

    #And crap out this HTML
		<div class="foo">
			<div class="bar">
				<div class="baz"></div>
			</div>
		</div>

## SCSS to HTML

`hum [stylesheet].scss`

		#He'll eat this SCSS
		.foo {
			color: white;
			.bar {
				color: black;
				.baz {
					color: red;
				}
			}
		}

		#And crap out this HTML
		<div class="foo">
			<div class="bar">
				<div class="baz"></div>
			</div>
		</div>

## CSS to HTML

`hum [stylesheet].css`

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
				<div class="baz"></div>
			</div>
		</div>

You can also watch a directory for changes to your SASS and SCSS files by using

`hum --watch`

## Notes

Just so you know, hum doesn't work well with mixins that include selectors yet.