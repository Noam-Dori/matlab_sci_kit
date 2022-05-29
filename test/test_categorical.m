%Define the colors' RGB values in a matrix
myData = Meas.from([1,2;2,3;3,4],[0.1;-1;2]);
myLabels = ["aaa";"bbb";"aaa"];

titles.title = "Brain Weight";
titles.y_axis = "Weight (g)";
titles.data = "%d";
titles.fit = [0;1;0];

cat_graph(myData, myLabels, titles, 0);