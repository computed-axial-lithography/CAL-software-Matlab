# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
import sys
sys.path.insert(0, os.path.abspath(os.path.join('..', '..')))

matlab_keep_package_prefix = False

matlab_src_dir = os.path.abspath('..')


print(matlab_src_dir)
# sys.path.append(os.path.abspath('../'))
# this_dir = os.path.dirname(os.path.abspath(__file__))
# matlab_src_dir = os.path.abspath(os.path.join(this_dir, '..','src'))
primary_domain = 'mat'

# -- Project information -----------------------------------------------------

project = 'CAL-software-Matlab'
copyright = '2021, University of California, Berkeley'
author = 'Joseph Toombs@*Sui Man (Nicole) LUK'

# The full version, including alpha/beta/rc tags
release = '1.2.1'


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
import sphinx_rtd_theme
extensions = [
    'sphinx_rtd_theme',
    'sphinxcontrib.matlab',
    'sphinx.ext.autodoc',
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_rtd_theme'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']
