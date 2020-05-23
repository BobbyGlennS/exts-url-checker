# EXTS URL Checker

The goal of this script is to automatically check all URLs in all markdown files of a repository (i.e. a repository with an EXTS course).

Exclusion criteria on the markdown file names as well as the URLs can be applied.

It works as follows:

This script extracts all active URLs from the markdown files in the repository, and runs a HEAD request on each of them.
It then stores the status code, or in case the request wasn't successful: the error message.

It outputs in a list the URLs with a non-200 status code or an error message, along with the file in which the URL appears, as well as the actual status code or error message.
For convenience it also outputs these results in a tibble.

## To do (my wishlist)

- Instead of checking a local repository: hook up directly to remote repository on GH or even to EXTS platform
- Create GH issues to relevant repository when URLs fail
- Wrap in an app / Rmd for RStudio connect