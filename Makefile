.PHONY: compile debug test quicktest clean all gen-errors gen-types


PYTHON ?= python
ROOT = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))


all: compile


clean:
	rm -fr $(ROOT)/dist/
	rm -fr $(ROOT)/doc/_build/
	rm -fr $(ROOT)/edgedb/pgproto/*.c
	rm -fr $(ROOT)/edgedb/pgproto/*.html
	rm -fr $(ROOT)/edgedb/pgproto/codecs/*.html
	rm -fr $(ROOT)/edgedb/protocol/*.c
	rm -fr $(ROOT)/edgedb/protocol/*.html
	rm -fr $(ROOT)/edgedb/protocol/*.so
	rm -fr $(ROOT)/build
	rm -fr $(ROOT)/*.egg-info
	rm -fr $(ROOT)/edgedb/protocol/codecs/*.html
	find . -name '__pycache__' | xargs rm -rf


compile:
	find $(ROOT)/edgedb/protocol -name '*.pyx' | xargs touch
	find $(ROOT)/edgedb/protocol/datatypes -name '*.c' | xargs touch
	$(PYTHON) setup.py build_ext --inplace


gen-errors:
	edb gen-errors --import "from edgedb.errors._base import *" \
		--extra-all "_base.__all__" --stdout --client > $(ROOT)/.errors
	mv $(ROOT)/.errors $(ROOT)/edgedb/errors/__init__.py


gen-types:
	edb gen-types --stdout > $(ROOT)/edgedb/protocol/codecs/edb_types.pxi


debug:
	EDGEDB_DEBUG=1 $(PYTHON) setup.py build_ext --inplace


test:
	PYTHONASYNCIODEBUG=1 $(PYTHON) setup.py test
	$(PYTHON) setup.py test
	USE_UVLOOP=1 $(PYTHON) setup.py test


testinstalled:
	cd /tmp && $(PYTHON) $(ROOT)/tests/__init__.py
	cd /tmp && USE_UVLOOP=1 $(PYTHON) $(ROOT)/tests/__init__.py


quicktest:
	$(PYTHON) setup.py test


htmldocs:
	$(PYTHON) setup.py build_ext --inplace
	$(MAKE) -C docs html
