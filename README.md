# Hum

Hum generates HTML from your SASS, SCSS or CSS. **For now you need Ruby 1.9 and above.** 

`gem install hum`

If you're using Windows also install this gem.

`gem install win32console`

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
				<div class="baz">Inner content</div>
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
				<div class="baz">Inner content</div>
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
		.foo .bar .baz{
			color: black;
		}

		#And crap out this HTML
		<div class="foo">
			<div class="bar">
				<div class="baz">Inner content</div>
			</div>
		</div>

You can also watch a directory for changes to your SASS and SCSS files by using

`hum --watch`

## Notes

Hum doesn't work well with mixins that include selectors yet. Hum doesn't let you specify unique content for each HTML tag. Hum is pretty basic at the moment, so don't be too rough!  