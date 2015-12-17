all : create_random_graph instances

override CXXFLAGS += -O3 -march=native -std=c++14 -I./ -W -Wall -g -ggdb3 -pthread

create_random_graph : create_random_graph.cc
	$(CXX) $(CXXFLAGS) -o $@ create_random_graph.cc $(LDFLAGS) \
	    -lboost_regex -lboost_thread -lboost_system -lboost_program_options

instances : create_random_graph ps30-ts150-phase-region.txt
	while read p tl tu ; do for s in $$(seq 1 8 ) ; do ./create_random_graph 30 $$p $$p $$(echo $$p$$tl$$tu$$s | tr -d 0. | rev ) > ../instances/phase/phase-30-150-$$p-$$tl-$$tu-$$s-pattern ; ./create_random_graph 150 $$tl $$tu $$(echo $$p$$tl$$tu$$s | tr -d 0. ) > ../instances/phase/phase-30-150-$$p-$$tl-$$tu-$$s-target ; done ; done < ps30-ts150-phase-region.txt
