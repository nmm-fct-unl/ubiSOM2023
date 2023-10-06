import numpy as np
import matplotlib.pyplot as plt
import gzip
import sys



som_cols = 40
som_lines = 20

### File name is the first argument
prototypes_file = sys.argv[1]
## prototypes_file = "prototypes_178.csv"

def std_abs(v, m):
	return int(sum(np.abs(v-m)))



def pack_features(v):
	return pack_features_gran(v)


# %%%

#%%%

n_curs = 0

def wait_info(n):
	global n_curs
	curs=".|/-\\|/-\\"
	sys.stdout.write("\r"+"{:9.3f}  ".format(n/1000.0)+curs[n_curs]+"      ")
	n_curs += 1
	if(n_curs >= len(curs)): n_curs = 0



#%%%

def read_prototypes(fn):
	with open(fn) as f:
		lns = f.readlines()
	m = []
	i = 1
	hd = lns[0].strip().split(',')
	for l in range(som_cols):
		l = []
		for c in range(som_lines):
			vals = lns[i].strip().split(',')
			vals[-1] = int(float(vals[-1])*100)  ## new Umat val as float
			l.append(np.array([int(v) for v in vals]))
			i += 1
		m.append(l)
	return hd,m

def get_component(i,mc):
	#m = np.zeros([som_cols, som_lines])  ## -- esta rotacao eh visualmente melhor, mas
										  ## eh dificil comparar com multisom 
	m = np.zeros([som_lines, som_cols])
	for x in range(som_cols):
		for y in range(som_lines):
			v= mc[x][y][i]
			m[som_lines-y-1,x]= v
			#m[x,y] = v ## rotacao mais adequada, mas dificil de compara com multiSOM (out 2022)
	return m


def show_heatmap(a, t = None):
	plt.imshow(a, cmap='jet', interpolation='nearest')
	if t != None:
		plt.title(t)
	plt.grid(True)
	plt.pause(0.001)

def show_component(v,t = None):
	if t != None:
		show_heatmap(get_component(v, m), t)
	else:
		show_heatmap(get_component(v, m), hd[v])

def show_CPs(hd, N):
	## https://stackoverflow.com/questions/46615554/how-to-display-multiple-images-in-one-figure-correctly


	plt.title("CPs "+prototypes_file[prototypes_file.rfind('/')+1:-4]) # -1+1 =0 on not found
	plt.xticks( )
	plt.yticks( )
	#axis('off')

	if N > 36:
		N = 36
		println("N>36 : cut on 6x6 ")

	if N < 3:
		max_cols = 2
		max_rows = 1
	elif N < 5:
		max_cols = N
		max_rows = 1
	elif(N < 10):
		max_cols = 3
		max_rows = 3
	elif(N < 17):
		max_cols = 4
		max_rows = 4
	elif(N < 26):
		max_cols = 5
		max_rows = 5
	elif(N < 37):
		max_cols = 6
		max_rows = 6
	else:
		cnt_show = 36
		println("cut on 6 rows")
		max_cols = 6
		max_rows = 6
	fig = plt.figure(3, figsize=(max_cols*3, max_rows*3))
	#axes.set_yticklabels([])
	#axes.set_xticklabels([])
	for i in range(0,N):
		#ax = fig.add_subplot(2,int(N/2+0.99),i+1)
		#print(" @:", max_rows, max_cols, i+1)
		ax = fig.add_subplot(max_rows, max_cols, i+1)
		ax.set_title(hd[i])
		show_component(i)

		#col += 1
		#if(col>max_cols):
		#	col =1 
		#	row += 1
		#	if row>6:
		#		println("cut after 6 rows")
		#		break; 


def show_som_viz():
	plt.figure(1)
	show_component(umat_c, "umat: "+prototypes_file[prototypes_file.rfind('/')+1:-4])
	#plt.show()
	plt.figure(2)
	show_component(cnt_c, "cnt: "+prototypes_file[prototypes_file.rfind('/')+1:-4])
	#plt.show()
	show_CPs(hd, cnt_c )

#%%%

def m2npm(m):
	nF = len(m[0][0]) -2 ## ignora componentes cnt e umat
	npm = np.zeros([som_lines*som_cols, nF])

	for x in range(som_cols):
		for y in range(som_lines):
			for i in range(nF):
				#print(x,y,i)
				npm[x*som_lines+y,i] = m[x][y][i]
	return npm

def get_bmu(npm,v):
	s = np.sum(np.power(npm - v,2),1) ## ignora componentes cnt e umat e soma linhas
	idx = np.argmin(s)
	return int(idx/som_lines), idx%som_lines, np.sqrt(s[idx])/1000.0

def test_get_bmu():
	x,y,d = get_bmu(npm, npm[0])
	assert x==0 and y == 0 and d == 0.0, "error get_bmu for p[0]"

	x,y,d = get_bmu(npm, npm[1])
	assert x==0 and y == 1 and d==0.0, "error get_bmu for p[1]"

	x,y,d = get_bmu(npm, npm[41])
	assert x==2 and y == 1 and d==0.0, "error get_bmu for p[1]"

	x,y,d = get_bmu(npm, npm[88])
	assert x==4 and y == 8 and d==0.0, "error get_bmu for p[1]"



#%%%

# print current folder
import os
print("Folder:", os.getcwd())

hd, m = read_prototypes(prototypes_file)

print("read "+ prototypes_file)

umat_c = len(hd)-1
cnt_c = len(hd)-2

npm = m2npm(m)

test_get_bmu()

show_som_viz()

plt.show()
# %%%
