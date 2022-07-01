\setcounter{figure}{0}

# Title
_Name, Surname_

_Le-Point-Technique_, _Month/Year_

__abstract__: blablablablabla

__keywords__: bla1, bla2

## Section I
### Subsection I

Check this link [link](google.fr).

Please check _Figure 1_

> ![legend](https://user-images.githubusercontent.com/6229031/142882134-04839c93-ce4d-4af5-88f6-97feb5cf7373.png)
> <pre>
> Figure 1: legend
> </pre>

I am joining table either as a figure or using [pandoc tables](https://pandoc.org/MANUAL.html#tables).

Please check _Table 1_. Note the hack with the lack of closing `</pre>` tag,
enforcing tables to be rendered as text in markdown (and in the same time not be ignored by pandoc).

_Table 1: legend_

<div><pre>
+---------------+---------------+
| Fruit         | Price         | 
+===============+===============+
| Bananas       | $1.34         |
|               |               |
+---------------+---------------+
| Oranges       | $2.10         |
|               |               |
+---------------+---------------+
</div>

Here is an awesome list:

- first item

- second item

### Subsection II
## Section II

## References

Use the Chicago Manual of Style 17th Edition (full note), e.g.:

‘Web API Fuzz Testing | GitLab’. Accessed 29 June 2022.
[https://docs.gitlab.com/ee/user/application_security/api_fuzzing/](https://docs.gitlab.com/ee/user/application_security/api_fuzzing/).
