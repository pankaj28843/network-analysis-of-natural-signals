clc;
clear all;
close all;

[y, Fs, nbits, readinfo] =wavread('canadas.wav');

[S, F, T, P] = spectrogram(y, hann(1024), 512, 1024, Fs);

[M, N] = size(P);

Q = M/N;

C_orig = corr(P);
[V_orig, D_orig] = eig(C_orig);

P_random = randomize(P);

C_random = corr(P_random);

lambda_max = (1 + 1/sqrt(Q))^2;
lambda_min = (1 - 1/sqrt(Q))^2;

[V_random, D_random] = eig(C_random);

filtered_eigenvalues = [];
filtered_eigenvectors = [];

[filtered_eigenvalues] = [filtered_eigenvalues; zeros(1,N)];
[filtered_eigenvectors] = [filtered_eigenvectors; zeros(1,N)];

for i = 2:N
    if D_random(i,i) < lambda_max && D_random(i,i) > lambda_min
        [filtered_eigenvalues] = [filtered_eigenvalues; zeros(1,N)];
        [filtered_eigenvectors] = [filtered_eigenvectors; zeros(1,N)];
    else
        [filtered_eigenvalues] = [filtered_eigenvalues; D_random(i, :)];
        [filtered_eigenvectors] = [filtered_eigenvectors; V_random(i, :)];
        
    end
end

spectrogram(y, hanning(1024), 512, 1024, Fs);
C_orig = corr(P');
%figure, imagesc(C_orig), colorbar;
min(C_orig);
min(min(C_orig));
max(max(C_orig));

AA=0.5+0.5*sign(C_orig);

%figure, imagesc(AA);


doc = com.mathworks.xml.XMLUtils.createDocument('gexf');
docRoot = doc.getDocumentElement;
docRoot.setAttribute('xmlns', 'http://www.gexf.net/1.2draft');
docRoot.setAttribute('version', '1.2');

meta = doc.createElement('meta');
meta.setAttribute('lastmodified', date);
creator = doc.createElement('creator');
creator.appendChild(doc.createTextNode('Pankaj Singh'));
description = doc.createElement('description');
description.appendChild(doc.createTextNode('Here goes description'));
meta.appendChild(creator);
meta.appendChild(description);

docRoot.appendChild(meta);

graph = doc.createElement('graph');
graph.setAttribute('mode', 'static');
graph.setAttribute('defaultedgetype', 'undirected');

nodes = doc.createElement('nodes');
edges = doc.createElement('edges');

edge_id = 0;

for i=1:M
    node = doc.createElement('node');
    node.setAttribute('id', sprintf('%i', i-1));
    node.setAttribute('label', sprintf('%f Hz ', F(i)));
    nodes.appendChild(node);
    for j=1:i
        if AA(i,j) > 0
            edge = doc.createElement('edge');
            edge.setAttribute('id', sprintf('%i', edge_id));
            edge.setAttribute('source', sprintf('%i', i-1));
            edge.setAttribute('target', sprintf('%i', j-1));
            edges.appendChild(edge);
            edge_id = edge_id + 1;
        end
    end
end

graph.appendChild(nodes);
graph.appendChild(edges);

docRoot.appendChild(graph);

xmlwrite('graph.gexf', doc);